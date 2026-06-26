class ApplicationController < ActionController::API
  def root
    render json: { message: "Welcome to Goalbook." }
  end

  private

  def authenticate!
    token = request.headers['x-access-token']
    return render json: { message: 'No token provided!' }, status: :unauthorized unless token

    decoded = JWT.decode(token, ENV['JWT_SECRET_KEY'], true, algorithm: 'HS256')[0]
    @current_user_id = decoded['id']
  rescue JWT::DecodeError
    render json: { message: 'Unauthorized!' }, status: :unauthorized
  end

  def generate_jwt(user)
    exp = Time.now.to_i + ENV['JWT_EXP_TIME'].to_i
    JWT.encode({ id: user.id, exp: exp }, ENV['JWT_SECRET_KEY'], 'HS256')
  end
end
