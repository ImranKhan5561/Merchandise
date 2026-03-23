class User < ApplicationRecord
  has_many :addresses, dependent: :destroy
  has_many :orders, dependent: :restrict_with_error
  has_one :cart, dependent: :destroy
  include Devise::JWT::RevocationStrategies::JTIMatcher

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  def jwt_payload
    super
  end

  before_create :generate_otp
  before_validation :set_default_verified, on: :create
  after_create_commit :send_otp_email

  def generate_otp
    self.otp_code = Array.new(6) { rand(0..9) }.join
    self.otp_expires_at = 15.minutes.from_now
  end

  def send_otp_email
    ::BrevoEmailService.send_otp(self)
  end

  private

  def set_default_verified
    self.is_verified ||= false
  end

  enum :role, {
    user: 0,
    admin: 1
  }
end
