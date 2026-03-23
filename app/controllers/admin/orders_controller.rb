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
      redirect_to admin_order_path(@order), notice: "Order successfully updated."
    else
      redirect_to admin_order_path(@order), alert: "Failed to update order."
    end
  end

  private

  def order_params
    params.require(:order).permit(:status, :payment_status)
  end
end
