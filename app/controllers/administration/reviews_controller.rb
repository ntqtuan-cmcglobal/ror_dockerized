module Administration
  class ReviewsController < ApplicationController
    before_action :authenticate_user!
    def index
      @q = Review.ransack(params[:q])
      @reviews = @q.result
                   .includes(:user)
                   .page(params[:page])
                   .per(params[:per_page])
                   .order(created_at: :desc)
      @model = Review
      authorize @reviews
    end

    def show
      @review = Review.find(params[:id])
      # Find the page number where the review appears
      reviews = Review.where(product_id: @review.product_id).order(created_at: :desc)
      index = reviews.pluck(:id).index(@review.id)
      page = (index / Review.default_per_page) + 1
      redirect_to product_path(@review.product_id, page: page, anchor: "review-#{@review.id}",
                                                   highlight_review: @review.id)
    end

    def destroy
      @review.destroy
      redirect_to administration_reviews_path, notice: 'Review was successfully deleted.'
    end

    private

    def review_params
      params.require(:review).permit(:product_id, :comment, :rating, :user_id)
    end
  end
end
