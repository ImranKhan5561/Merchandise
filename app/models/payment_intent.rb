class PaymentIntent < ApplicationRecord
  belongs_to :user
  belongs_to :order

  validates :external_id, uniqueness: true, allow_nil: true
end
