class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy

  enum :status, { pending: 0, confirmed: 1, shipped: 2, delivered: 3, cancelled: 4 }
  enum :payment_status, { unpaid: 0, paid: 1, refunded: 2 }

  validates :order_number, presence: true, uniqueness: true
  validates :subtotal, :total_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }

  before_validation :generate_order_number, on: :create

  private

  def generate_order_number
    self.order_number ||= "ORD-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(4).upcase}"
  end
end
