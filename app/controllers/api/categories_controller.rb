class Api::CategoriesController < Api::ApplicationController
  def index
    categories = Category.where(parent_id: nil).includes(:children)
    render json: categories.map { |cat|
      {
        id: cat.id,
        name: cat.name,
        image_url: cat.image.attached? ? url_for(cat.image) : nil,
        children: cat.children.map { |child| 
          { 
            id: child.id, 
            name: child.name,
            image_url: child.image.attached? ? url_for(child.image) : nil
          } 
        }
      }
    }
  end
end
