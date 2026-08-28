class ServiceablePincode < ApplicationRecord
  validates :code, presence: true, uniqueness: true

  scope :active, -> { where(active: true) }
end
