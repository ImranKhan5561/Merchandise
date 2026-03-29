class Api::AuthController < Api::ApplicationController
  skip_before_action :authenticate_user!, only: [:verify_otp, :resend_otp], raise: false

  def resend_otp
    user = User.find_by(email: params[:email])
    if user
      user.generate_otp
      user.save(validate: false)
      user.send_otp_email
      render json: { status: { code: 200, message: 'OTP resent successfully.' } }, status: :ok
    else
      render json: { status: { message: 'User not found.' } }, status: :not_found
    end
  end

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
