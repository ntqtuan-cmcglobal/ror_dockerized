class ReviewsController < ApplicationController
  def index
    @order_items = OrderItem.page(params[:page])
    # This will work because @order_items is paginated
    @total_pages = @order_items.total_pages
  end

  def show
    @review = Review.find(params[:id])
  end

  def new
    @review = Review.new
  end

  def create
    @review = Review.new(review_params)
    if @review.save
      redirect_to @review.product, notice: 'Review was successfully created.'
    else
      render :new
    end
  end

  def edit
    @review = Review.find(params[:id])
  end

  def update
    @review = Review.find(params[:id])
    if @review.update(review_params)
      redirect_to @review.product, notice: 'Review was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @review = Review.find(params[:id])
    @review.destroy
    redirect_to @review.product, notice: 'Review was successfully deleted.'
  end

  private

  def review_params
    params.require(:review).permit(:product_id, :user_id, :rating, :comment)
  end
end
