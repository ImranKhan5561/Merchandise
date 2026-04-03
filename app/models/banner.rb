class Banner < ApplicationRecord
  validates :title, :image_url, presence: true
  validates :position, numericality: { only_integer: true }

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(position: :asc, created_at: :desc) }
end
