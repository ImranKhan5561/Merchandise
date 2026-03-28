class Api::WishlistItemsController < Api::ApplicationController
  before_action :authenticate_user!

  def index
    products = current_user.wishlisted_products.with_attached_images.includes(:category)
    render json: {
      products: products.map { |p| serialize_product_card(p) }
    }
  end

  def create
    product = Product.find(params[:product_id])
    wishlist_item = current_user.wishlist_items.find_or_initialize_by(product: product)
    
    if wishlist_item.save
      render json: { message: 'Product added to wishlist', product_id: product.id }, status: :created
    else
      render json: { errors: wishlist_item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    wishlist_item = current_user.wishlist_items.find_by(product_id: params[:id])
    
    if wishlist_item
      wishlist_item.destroy
      render json: { message: 'Product removed from wishlist', product_id: params[:id].to_i }
    else
      render json: { error: 'Product not found in wishlist' }, status: :not_found
    end
  end
end
