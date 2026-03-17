class Product < ApplicationRecord
  belongs_to :category

  has_many_attached :images
  
  has_many :variants, dependent: :destroy
  has_many :product_option_types, dependent: :destroy
  has_many :option_types, through: :product_option_types
  has_many :product_specifications, dependent: :destroy
  has_many :variant_image_sets, dependent: :destroy
  
  # For the "Master Variant" pattern
  has_one :master_variant, -> { where(is_master: true) }, class_name: "Variant"

  accepts_nested_attributes_for :variants, allow_destroy: true
  accepts_nested_attributes_for :product_specifications, allow_destroy: true, reject_if: :all_blank

  before_validation :ensure_unique_slug

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :discount_percentage, numericality: { 
    only_integer: true, 
    greater_than_or_equal_to: 0, 
    less_than_or_equal_to: 100 
  }, allow_nil: true
  validate :compare_at_price_greater_than_base_price

  # Scopes
  scope :featured, -> { where(featured: true) }

  # Get option types marked as visual for this product
  def visual_option_types
    product_option_types.where(is_visual: true).includes(:option_type).map(&:option_type)
  end

  # Check if product is on sale
  def on_sale?
    compare_at_price.present? && compare_at_price > (base_price || 0)
  end

  # Calculate discount percentage from prices if not manually set
  def calculated_discount
    return discount_percentage if discount_percentage.present?
    return 0 unless on_sale? && compare_at_price.to_f > 0
    
    ((compare_at_price - base_price) / compare_at_price * 100).round
  end

  # Display price (current sale price)
  def display_price
    base_price
  end

  private

  def compare_at_price_greater_than_base_price
    if compare_at_price.present? && base_price.present? && compare_at_price <= base_price
      errors.add(:compare_at_price, "must be greater than base price")
    end
  end

  def ensure_unique_slug
    return if slug.blank?
    
    original_slug = slug
    counter = 2
    
    # Check if slug already exists (excluding self for updates)
    while Product.where(slug: slug).where.not(id: id).exists?
      self.slug = "#{original_slug}-#{counter}"
      counter += 1
    end
  end
end
