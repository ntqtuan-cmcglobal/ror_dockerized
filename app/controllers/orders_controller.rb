class OrdersController < ApplicationController
  before_action :authenticate_user!

  def create
    @cart = if params[:cart_id].present?
              Cart.find(params[:cart_id])
            else
              current_user.cart
            end

    redirect_to root_path, alert: 'Cart not found.' and return unless @cart

    seller_ids = @cart.cart_items.map { |item| item.product.user_id }.uniq
    if seller_ids.size != 1
      redirect_to @cart, alert: 'All products in the order must be from the same seller.' and return
    end

    @order = Order.new(
      user_id: current_user.id,
      status: OrderStatus::UNPAID,
      total_price: @cart.cart_items.sum { |item| item.quantity * item.product.price }
    )

    @cart.cart_items.each do |item|
      @order.order_items.build(
        product_id: item.product_id,
        quantity: item.quantity,
        price: item.product.price
      )
    end

    authorize @order
    if @order.save
      @cart.cart_items.destroy_all
      redirect_to @order, notice: 'Order was successfully created from cart.'
    else
      redirect_to @cart, alert: 'Failed to create order. Please check your input.'
    end
  end

  def show
    @order = Order.find(params[:id])
    authorize @order
  end

  def index
    @q = policy_scope(Order).ransack(params[:q])
    @orders = @q.result
    @orders = @orders.where(user_id: current_user.id) if current_user.buyer?
    @orders = @orders.page(params[:page]).order(created_at: :desc)

    @total_outcome = @orders.unscope(:limit, :offset).select { |o| o.status.in?(%w[paid completed]) }.sum(&:total_price)
    authorize @orders
  end

  def cancel_order
    @order = Order.find(params[:id])
    authorize @order
    if @order.status == OrderStatus::UNPAID
      @order.status = OrderStatus::CANCELLED
      if @order.save(validate: false)
        redirect_to @order, notice: 'Order was successfully cancelled.'
      else
        redirect_to @order, alert: 'Failed to cancel order.'
      end
    else
      redirect_to @order, alert: 'Only unpaid orders can be cancelled.'
    end
  end

  private

  def order_params
    params.require(:order).permit(:cart_id)
  end
end
