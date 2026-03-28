module Api
  class OrdersController < ApplicationController
    before_action :authenticate_user!

    def index
      orders = current_user.orders.includes(:order_items).order(created_at: :desc)
      render json: orders, include: :order_items
    end

    def show
      order = current_user.orders.find(params[:id])
      render json: order, include: :order_items
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Order not found' }, status: :not_found
    end

    def create
      cart = current_user.cart
      return render json: { error: "Cart is empty" }, status: :unprocessable_entity unless cart
      
      items = cart.cart_items.where(id: params[:cart_item_ids])
      return render json: { error: "No items selected" }, status: :unprocessable_entity if items.empty?

      address = current_user.user_addresses.find_by(id: params[:address_id])
      return render json: { error: "Invalid address" }, status: :unprocessable_entity unless address

      subtotal = items.sum { |item| item.price * item.quantity }
      shipping_fee = subtotal > 50 ? 0 : 5.00
      tax = subtotal * 0.08
      total_amount = subtotal + shipping_fee + tax

      ActiveRecord::Base.transaction do
        # LOCK variants to avoid race conditions
        items.each do |item|
          if item.variant
            item.variant.lock!
            if item.quantity > item.variant.stock_quantity.to_i
              raise ActiveRecord::Rollback, "Insufficient stock for \#{item.product.name}"
            end
          else
            item.product.lock!
            if item.quantity > item.product.total_stock.to_i
               raise ActiveRecord::Rollback, "Insufficient stock for \#{item.product.name}"
            end
          end
        end

        order = current_user.orders.create!(
          payment_method: params[:payment_method] || 'cod',
          payment_status: params[:payment_method] == 'cod' ? :unpaid : :paid,
          status: :pending,
          subtotal: subtotal,
          shipping_fee: shipping_fee,
          tax: tax,
          total_amount: total_amount,
          shipping_name: current_user.name,
          shipping_phone: "N/A", # Add phone to user/address later if needed
          shipping_address: "\#{address.address_line_1} \#{address.address_line_2}".strip,
          shipping_city: address.city,
          shipping_state: address.state,
          shipping_pincode: address.postal_code,
          shipping_country: address.country
        )

        items.each do |item|
          order.order_items.create!(
            product: item.product,
            product_name: item.product.name,
            variant: item.variant,
            variant_sku: item.variant&.sku,
            quantity: item.quantity,
            price: item.price,
            image_url: item.variant&.display_images&.first&.id || item.product.images.first&.id # Or however images are handled, just a placeholder if needed
          )

          # Deduct stock
          if item.variant
            item.variant.decrement!(:stock_quantity, item.quantity)
          else
            item.product.decrement!(:total_stock, item.quantity)
          end
        end

        # Remove ONLY ordered items from cart
        items.destroy_all

        render json: { success: true, order: order }, status: :created
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.message }, status: :unprocessable_entity
      rescue StandardError => e
        render json: { error: e.message || "Order failed" }, status: :unprocessable_entity
      end
    end

    def cancel
      order = current_user.orders.find(params[:id])
      
      if order.status != 'pending'
        return render json: { error: 'Only pending orders can be cancelled' }, status: :unprocessable_entity
      end

      ActiveRecord::Base.transaction do
        order.update!(status: :cancelled)
        
        order.order_items.each do |item|
          if item.variant
            item.variant.lock!
            item.variant.increment!(:stock_quantity, item.quantity)
          else
            item.product.lock!
            item.product.increment!(:total_stock, item.quantity)
          end
        end
      end
      
      render json: { success: true, order: order }
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Order not found' }, status: :not_found
    rescue StandardError => e
      render json: { error: e.message || 'Failed to cancel order' }, status: :unprocessable_entity
    end
  end
end
