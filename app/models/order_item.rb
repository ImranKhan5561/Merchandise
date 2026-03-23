class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product
  belongs_to :variant, optional: true

  validates :product_name, :price, :quantity, presence: true
  validates :quantity, numericality: { greater_than: 0 }
  validates :price, numericality: { greater_than_or_equal_to: 0 }
end
