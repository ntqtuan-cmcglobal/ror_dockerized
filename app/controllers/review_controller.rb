class ReviewController < ApplicationController
  def index
    @order_items = OrderItem.page(params[:page])
    # This will work because @order_items is paginated
    @total_pages = @order_items.total_pages
  end

  def show
    @order_items = OrderItem.all
    # This will NOT work because @order_items is not paginated
    @total_pages = begin
      @order_items.total_pages
    rescue StandardError
      nil
    end
  end

  def create
    @review = Review.new(review_params)

    if @review.save
      # @review.product.update(average_rating: @review.product.reviews.average(:rating))
      redirect_to @review.product, notice: 'Review was successfully created.'
    else
      render :new
    end
  end

  private

  def review_params
    params.require(:review).permit(:product_id, :user_id, :rating, :comment)
  end
end
