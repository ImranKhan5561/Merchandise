class ProductOptionType < ApplicationRecord
  belongs_to :product
  belongs_to :option_type

  validates :product_id, uniqueness: { scope: :option_type_id }

  scope :visual, -> { where(is_visual: true) }
  
  default_scope { order(:position) }

  delegate :presentation, :name, :option_values, to: :option_type
end
