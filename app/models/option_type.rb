class OptionType < ApplicationRecord
  belongs_to :category, optional: true
  has_many :product_option_types, dependent: :destroy
  has_many :products, through: :product_option_types
  has_many :option_values, dependent: :destroy
  
  validates :name, presence: true, uniqueness: true
  validates :presentation, presence: true
  
  accepts_nested_attributes_for :option_values, allow_destroy: true, reject_if: :all_blank
  
  # Scope to get option types for a specific category (or global ones)
  scope :for_category, ->(category) { 
    where(category_id: [nil, category&.id]) 
  }
end
