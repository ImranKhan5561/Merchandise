class Category < ApplicationRecord
  belongs_to :parent, class_name: "Category", optional: true
  has_many :children, class_name: "Category", foreign_key: "parent_id", dependent: :destroy
  has_many :products, dependent: :nullify
  has_many :option_types, dependent: :nullify
  
  has_one_attached :image

  validates :name, presence: true
end
