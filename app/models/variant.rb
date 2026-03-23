class Variant < ApplicationRecord
  has_many :order_items, dependent: :restrict_with_error
  belongs_to :product
  has_and_belongs_to_many :option_values

  has_many_attached :images

  validates :sku, presence: true, uniqueness: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  # Helper to get specific option value (e.g. "Color" value)
  def option_value(name)
    option_values.joins(:option_type).find_by(option_types: { name: name })&.presentation
  end

  # Get images to display: variant-specific > product fallback
  def display_images
    return images if images.attached?
    product.images
  end
end
