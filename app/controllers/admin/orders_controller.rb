class Admin::OrdersController < Admin::BaseController
  def index
    authorize Order
    @orders = Order.includes(:user).order(created_at: :desc)
  end

  def show
    authorize Order
    @order = Order.includes(order_items: [:product, :variant]).find(params[:id])
  end
  def update
    authorize Order
    @order = Order.find(params[:id])
    if @order.update(order_params)
      respond_to do |format|
        format.html { redirect_back fallback_location: admin_orders_path, notice: "Order successfully updated." }
        format.turbo_stream { render turbo_stream: "" }
      end
    else
      respond_to do |format|
        format.html { redirect_back fallback_location: admin_orders_path, alert: "Failed to update order." }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("order_#{@order.id}", partial: "admin/orders/order", locals: { order: @order, error: "Failed to update." }) }
      end
    end
  end

  private

  def order_params
    params.require(:order).permit(:status, :payment_status)
  end
end
