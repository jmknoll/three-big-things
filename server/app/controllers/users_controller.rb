class UsersController < ApplicationController
  before_action :authenticate!, only: [:me]

  def create
    user = User.create!(email: params[:email], password: params[:password])
    render json: user
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  def me
    user = User.find(@current_user_id)

    tz = params[:tzOffset].to_i
    user.update(timezone_offset: tz) if tz != user.timezone_offset

    # Streak logic (mirrors existing Node logic)
    if user.last_login.present?
      local_last_login = user.last_login - user.timezone_offset.to_i.minutes
      local_now = Time.now.utc - user.timezone_offset.to_i.minutes
      last_day = local_last_login.yday
      now_day = local_now.yday
      diff = now_day - last_day

      if diff != 0
        new_streak = if diff == 1 || (now_day == 1 && diff == -364)
          (user.streak || 0) + 1
        else
          1
        end
        user.update(streak: new_streak, last_login: Time.now.utc)
      end
    else
      user.update(last_login: Time.now.utc, streak: 1)
    end

    token = generate_jwt(user)
    render json: { token: token, user: user }
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end
end
