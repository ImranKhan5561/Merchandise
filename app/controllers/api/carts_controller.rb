class Api::CartsController < Api::ApplicationController
  before_action :authenticate_user!

  def show
    cart = current_user.cart || current_user.create_cart
    render json: cart_as_json(cart)
  end

  def add_item
    cart = current_user.cart || current_user.create_cart
    variant = Variant.find(params[:variant_id])
    product = variant.product
    
    cart_item = cart.cart_items.find_or_initialize_by(variant: variant, product: product)
    base_qty = cart_item.new_record? ? 0 : cart_item.quantity
    cart_item.quantity = base_qty + params[:quantity].to_i
    cart_item.price = variant.price
    
    if cart_item.save
      render json: cart_as_json(cart)
    else
      render json: { errors: cart_item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update_item
    cart = current_user.cart
    return render json: { error: 'Cart not found' }, status: :not_found unless cart

    cart_item = cart.cart_items.find_by(variant_id: params[:variant_id])
    return render json: { error: 'Item not found' }, status: :not_found unless cart_item

    if params[:quantity].to_i <= 0
      cart_item.destroy
    else
      cart_item.update(quantity: params[:quantity].to_i)
    end

    render json: cart_as_json(cart)
  end

  def remove_item
    cart = current_user.cart
    return render json: { error: 'Cart not found' }, status: :not_found unless cart

    cart_item = cart.cart_items.find_by(variant_id: params[:variant_id])
    cart_item&.destroy
    
    render json: cart_as_json(cart)
  end

  private

  def cart_as_json(cart)
    {
      id: cart.id,
      total_price: cart.total_price.to_f,
      items: cart.cart_items.map do |item|
        {
          id: item.id,
          product_id: item.product_id,
          product_name: item.product.name,
          product_slug: item.product.slug,
          variant_id: item.variant_id,
          sku: item.variant.sku,
          quantity: item.quantity,
          price: item.price.to_f,
          total_price: item.total_price.to_f,
          image: image_urls(item.variant.images).first || image_urls(item.product.images).first,
          options: item.variant.option_values.map { |ov| { name: ov.option_type.name, value: ov.presentation } }
        }
      end
    }
  end

  def image_urls(images)
    return [] unless images.attached?
    images.map { |img| url_for(img) }
  end
end
