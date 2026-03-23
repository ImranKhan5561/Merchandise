class Api::AuthController < Api::ApplicationController
  skip_before_action :authenticate_user!, only: [:verify_otp], raise: false

  def verify_otp
    user = User.find_by(email: params[:email])

    if user && user.otp_code == params[:otp_code] && user.otp_expires_at > Time.current
      user.update(is_verified: true, otp_code: nil, otp_expires_at: nil)
      render json: { 
        status: { code: 200, message: 'Account verified successfully.' },
        data: { user: user.as_json(only: [:id, :email, :name, :is_verified]) }
      }, status: :ok
    else
      render json: { 
        status: { message: 'Invalid or expired OTP code.' }
      }, status: :unprocessable_entity
    end
  end
end
