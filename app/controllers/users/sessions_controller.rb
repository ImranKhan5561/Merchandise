class Users::SessionsController < Devise::SessionsController
  skip_before_action :verify_authenticity_token
  respond_to :json

  private

  def respond_with(resource, _opts = {})
    if request.format.json?
      render json: {
        status: { code: 200, message: 'Logged in successfully.' },
        data: {
          user: resource.as_json(only: [:id, :email, :role, :created_at]),
          token: request.env['warden-jwt_auth.token']
        }
      }, status: :ok
    else
      super
    end
  end

  def respond_to_on_destroy
    if request.format.json?
      if current_user
        render json: {
          status: 200,
          message: "logged out successfully"
        }, status: :ok
      else
        render json: {
          status: 401,
          message: "Couldn't find an active session."
        }, status: :unauthorized
      end
    else
      super
    end
  end
end
