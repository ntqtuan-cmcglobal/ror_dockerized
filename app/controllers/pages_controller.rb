class PagesController < ApplicationController
  # before_action :authenticate_user!, only: %i[index new]

  def index
    if user_signed_in?
      # Get the most bought products based on order_items count, limit to 8
      @products = Product.joins(:order_items)
                         .group('products.id')
                         .order('COUNT(order_items.id) DESC')
                         .limit(8)
    else
      redirect_to new_user_session_path and return
    end
  end

  def selling_point
    # Find order items where the product belongs to the current user (seller)
    @order_items = OrderItem.joins(:product).where(products: { user_id: current_user.id }).joins(:order).where(orders: { status: OrderStatus::PAID })
  end

  def new; end
end
