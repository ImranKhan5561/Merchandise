class Api::ProfileController < Api::ApplicationController
  before_action :authenticate_user!

  def show
    render json: {
      status: { code: 200, message: 'Profile fetched successfully.' },
      data: {
        user: current_user.as_json(only: [:id, :email, :name, :is_verified, :role, :created_at])
      }
    }, status: :ok
  end

  def update
    if params[:user][:email].present? && params[:user][:email] != current_user.email
      current_user.is_verified = false
      # Note: Re-sending OTP logic would go here if needed
    end

    if current_user.update(user_params)
      render json: {
        status: { code: 200, message: 'Profile updated successfully.' },
        data: { user: current_user.as_json(only: [:id, :email, :name, :is_verified, :role, :created_at]) }
      }, status: :ok
    else
      render json: {
        status: { message: current_user.errors.full_messages.to_sentence }
      }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email)
  end
end
