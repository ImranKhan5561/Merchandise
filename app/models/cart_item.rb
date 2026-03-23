class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product
  belongs_to :variant

  validates :quantity, presence: true, numericality: { greater_than: 0 }

  def total_price
    (price || 0) * quantity
  end
end
