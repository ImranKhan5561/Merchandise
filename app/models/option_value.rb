class OptionValue < ApplicationRecord
  belongs_to :option_type
  has_and_belongs_to_many :variants
  
  validates :value, presence: true
  validates :presentation, presence: true
end
