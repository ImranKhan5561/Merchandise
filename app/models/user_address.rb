class UserAddress < ApplicationRecord
  belongs_to :user

  validates :address_type, :address_line_1, :city, :state, :postal_code, :country, :full_name, :phone_number, presence: true
  
  before_save :ensure_single_default

  private

  def ensure_single_default
    if is_default
      user.user_addresses.where.not(id: id).update_all(is_default: false)
    elsif user.user_addresses.where(is_default: true).count == 0
      self.is_default = true # First address is default
    end
  end
end
