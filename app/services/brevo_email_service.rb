require 'sib-api-v3-sdk'

class BrevoEmailService
  def self.send_otp(user)
    api_instance = SibApiV3Sdk::TransactionalEmailsApi.new
    
    sender_email = Rails.application.credentials.dig(:brevo, :sender_email)
    api_key = Rails.application.credentials.dig(:brevo, :api_key)
    
    Rails.logger.debug "--- Brevo Debug ---"
    Rails.logger.debug "Sender Email from credentials: #{sender_email}"
    Rails.logger.debug "API Key present: #{api_key.present?}"
    Rails.logger.debug "-------------------"

    send_smtp_email = SibApiV3Sdk::SendSmtpEmail.new(
      sender: { name: 'Ethereal Boutique', email: sender_email || 'no-reply@ethereal.com' },
      to: [{ email: user.email, name: user.name }],
      subject: 'Your Ethereal Verification Code',
      html_content: "
        <div style='font-family: serif; max-width: 600px; margin: 0 auto; padding: 40px; background: #FDFDFF; border: 1px solid #E6E1F9; border-radius: 40px;'>
          <h1 style='color: #1A142E; text-align: center; font-size: 32px;'>Welcome to Ethereal</h1>
          <p style='color: #6B6580; text-align: center; font-size: 14px; letter-spacing: 0.1em; text-transform: uppercase;'>Your Luxury Collection Awaits</p>
          <div style='background: white; padding: 40px; border-radius: 30px; margin: 40px 0; text-align: center; border: 1px solid #F0F0F7;'>
            <p style='color: #8B7BB4; font-[10px]; font-weight: 900; text-transform: uppercase; letter-spacing: 0.2em; margin-bottom: 20px;'>Verification Code</p>
            <h2 style='color: #1A142E; font-size: 48px; letter-spacing: 0.3em; margin: 0;'>#{user.otp_code}</h2>
          </div>
          <p style='color: #9A94B3; text-align: center; font-size: 12px;'>This code will expire in 15 minutes. If you did not request this, please ignore this email.</p>
        </div>
      "
    )

    begin
      result = api_instance.send_transac_email(send_smtp_email)
      Rails.logger.info "Brevo Email Sent! Result: #{result}"
    rescue SibApiV3Sdk::ApiError => e
      Rails.logger.error "Exception when calling TransactionalEmailsApi->send_transac_email: #{e}"
      Rails.logger.error "Response Body: #{e.response_body}"
    ensure
      # Fallback for development: Always log the OTP so we can test the flow
      Rails.logger.info "\n" + ("*" * 50)
      Rails.logger.info "DEVELOPMENT OTP FALLBACK"
      Rails.logger.info "User: #{user.email}"
      Rails.logger.info "OTP CODE: #{user.otp_code}"
      Rails.logger.info ("*" * 50) + "\n"
    end
  end
end
