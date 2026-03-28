class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy

  enum :status, { pending: 0, out_for_delivery: 1, delivered: 2, cancelled: 3 }
  enum :payment_status, { unpaid: 0, paid: 1, refunded: 2 }

  validates :order_number, presence: true, uniqueness: true
  validates :subtotal, :total_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }

  before_validation :generate_order_number, on: :create

  after_create_commit -> {
    broadcast_prepend_to "admin_orders",
      target: "admin_orders_list",
      partial: "admin/orders/order",
      locals: { order: self }
  }

  after_update_commit -> {
    broadcast_replace_to "admin_orders",
      target: "order_#{self.id}",
      partial: "admin/orders/order",
      locals: { order: self }
  }

  private

  def generate_order_number
    self.order_number ||= "ORD-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(4).upcase}"
  end
end
