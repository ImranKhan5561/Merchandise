class Api::ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  before_action :set_cors_headers

  private

  def set_cors_headers
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Methods'] = 'GET, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'Content-Type'
  end

  def render_json(data, status: :ok)
    render json: data, status: status
  end

  def serialize_product_card(product)
    {
      id: product.id,
      name: product.name,
      slug: product.slug,
      brand: product.brand,
      base_price: product.base_price.to_f,
      compare_at_price: product.compare_at_price&.to_f,
      discount: product.calculated_discount,
      on_sale: product.on_sale?,
      free_shipping: product.free_shipping,
      cover_image: product.images.attached? ? url_for(product.images.first) : nil,
      tags: product.tags,
      category: product.category&.name
    }
  end

  def image_urls(images)
    return [] unless images.attached?
    images.map { |img| url_for(img) }
  rescue
    []
  end
end
