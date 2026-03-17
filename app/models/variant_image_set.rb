class VariantImageSet < ApplicationRecord
  belongs_to :product
  has_many_attached :images

  validates :option_value_ids_key, presence: true
  validates :option_value_ids_key, uniqueness: { scope: :product_id }

  # Find or create image set for a combination of visual option values
  def self.for_values(product, option_value_ids)
    return nil if option_value_ids.blank?
    key = option_value_ids.map(&:to_i).sort.join("-")
    find_or_create_by(product: product, option_value_ids_key: key)
  end

  # Get the option values from the key
  def option_values
    return [] if option_value_ids_key.blank?
    ids = option_value_ids_key.split("-").map(&:to_i)
    OptionValue.where(id: ids)
  end

  # Human-readable label for this combination
  def label
    option_values.map(&:presentation).join(" + ")
  end
end
