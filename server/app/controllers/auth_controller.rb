class AuthController < ApplicationController
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
end
