class Api::CategoriesController < Api::ApplicationController
  def index
    categories = Category.where(parent_id: nil).includes(:children)
    render json: categories.map { |cat| serialize_category(cat) }
  end

  private

  def serialize_category(category)
    {
      id: category.id,
      name: category.name,
      image_url: category.image.attached? ? url_for(category.image) : nil,
      children: category.children.map { |child| serialize_category(child) }
    }
  end
end
