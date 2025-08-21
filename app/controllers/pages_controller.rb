class PagesController < ApplicationController
  # before_action :authenticate_user!, only: %i[index new]

  def index
    if user_signed_in?
      # Get the most bought products based on order_items count, limit to 8, eager load digital_asset_attachment
      @products = if current_user.buyer?
                    Product.where(is_draft: false)
                  else
                    Product.all
                  end
                  .order('products.average_rating DESC')
                  .limit(8)
                  .includes(:user, :category, digital_asset_attachment: :blob, video_thumbnail_attachment: :blob)
    else
      @products =
        Product.where(is_draft: false)
               .order('products.average_rating DESC')
               .limit(8)
               .includes(:user, :category, digital_asset_attachment: :blob, video_thumbnail_attachment: :blob)
    end
  end

  def selling_point
    # Find order items where the product belongs to the current user (seller)
    @order_items = OrderItem
                   .joins(:product)
                   .where(products: { user_id: current_user.id })
                   .joins(:order)
                   .where(
                     orders: { status: [OrderStatus::PAID, OrderStatus::COMPLETED, OrderStatus::UNPAID] }
                   )
                   .includes(:product, order: :user)
                   .page(params[:page])
                   .order(created_at: :desc)

    @total_income = @order_items.unscope(:limit, :offset).sum do |item|
      if item.order.status.in?(%w[paid completed])
        item.price.to_f
      else
        0
      end
    end
  end

  def new; end
end
