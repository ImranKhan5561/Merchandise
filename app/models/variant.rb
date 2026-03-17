class Variant < ApplicationRecord
  belongs_to :product
  has_and_belongs_to_many :option_values

  has_many_attached :images

  validates :sku, presence: true, uniqueness: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  # Helper to get specific option value (e.g. "Color" value)
  def option_value(name)
    option_values.joins(:option_type).find_by(option_types: { name: name })&.presentation
  end

  # Get the image set for this variant based on its visual option values
  def image_set
    # Get visual option type IDs from product
    visual_type_ids = product.product_option_types.where(is_visual: true).pluck(:option_type_id)
    return nil if visual_type_ids.empty?
    
    # Get this variant's option values that belong to visual option types
    visual_value_ids = option_values.where(option_type_id: visual_type_ids).pluck(:id)
    return nil if visual_value_ids.empty?
    
    key = visual_value_ids.sort.join("-")
    product.variant_image_sets.find_by(option_value_ids_key: key)
  end

  # Get images to display: variant-specific > image set > product fallback
  def display_images
    return images if images.attached?
    image_set&.images || product.images
  end
end
