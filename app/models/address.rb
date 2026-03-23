class Address < ApplicationRecord
  belongs_to :user

  validates :full_name, :mobile, :address_line, :city, :state, :country, :pincode, presence: true

  before_save :unset_other_defaults, if: -> { is_default? }

  private

  def unset_other_defaults
    user.addresses.where.not(id: id).update_all(is_default: false)
  end
end
