class Banner < ApplicationRecord
  has_one_attached :image

  validates :title, presence: true
  validates :position, numericality: { only_integer: true }

  before_validation :set_placeholder_image_url, on: [:create, :update]

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(position: :asc, created_at: :desc) }

  private

  def set_placeholder_image_url
    self.image_url = 'local_upload' if image_url.blank? && image.attached?
  end
end
