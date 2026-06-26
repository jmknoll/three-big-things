module V1
  class AuthController < V1::BaseController
    before_action :authenticate!, only: [:me, :update_me]

    def oauth
      payload = Google::Auth::IDTokens.verify_oidc(params[:token], aud: ENV['GAPI_CLIENT_ID'])

      user = User.find_or_create_by(email: payload['email']) do |u|
        u.timezone_offset = params[:tzOffset]
      end

      token = generate_jwt(user)
      render json: { token: token, user: user }, status: :created
    rescue => e
      render json: { error: e.message }, status: :internal_server_error
    end

    def email_signup
      if User.exists?(email: params[:email])
        render json: { error: "An account with that email already exists." }, status: :unprocessable_entity
        return
      end

      user = User.new(email: params[:email], name: params[:name], password: params[:password])
      user.timezone_offset = params[:tzOffset]

      unless user.save
        render json: { error: user.errors.full_messages.first || "Could not create account." }, status: :unprocessable_entity
        return
      end

      user.generate_confirmation_token!
      ResendMailer.send_confirmation(user)

      token = generate_jwt(user)
      render json: { token: token, user: user }, status: :created
    rescue => e
      render json: { error: e.message }, status: :internal_server_error
    end

    def email_signin
      user = User.find_by(email: params[:email])

      unless user&.authenticate(params[:password])
        render json: { error: "Invalid email or password." }, status: :unauthorized
        return
      end

      token = generate_jwt(user)
      render json: { token: token, user: user }
    rescue => e
      render json: { error: e.message }, status: :internal_server_error
    end

    def me
      user = User.find(@current_user_id)
      user.recalculate_streak!
      token = generate_jwt(user)
      render json: { token: token, user: user }
    end

    def update_me
      user = User.find(@current_user_id)
      user.update!(update_me_params)
      render json: { user: user }
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    def forgot_password
      user = User.find_by(email: params[:email].to_s.downcase.strip)
      if user&.password_digest.present?
        user.generate_password_reset_token!
        ResendMailer.send_password_reset(user)
      end
      # Always 200 — don't reveal whether the email exists.
      render json: { message: "If an account with that email exists, a reset link is on its way." }
    rescue => e
      render json: { error: e.message }, status: :internal_server_error
    end

    def resend_confirmation
      user = User.find_by(email: params[:email].to_s.downcase.strip)
      if user && !user.email_confirmed?
        user.generate_confirmation_token!
        ResendMailer.send_confirmation(user)
      end
      render json: { message: "If your email is unconfirmed, a new link is on its way." }
    rescue => e
      render json: { error: e.message }, status: :internal_server_error
    end

    private

    def update_me_params
      params.permit(:timezone_offset, :morning_reminder_time, :eod_reminder_time,
                    :notifications_enabled, :onboarding_done)
    end
  end
end
