class CartsController < ApplicationController
  include CartsHelper

  # Ensure the user is authenticated before accessing cart actions
  before_action :authenticate_user!
  # Initialize the cart for the user
  before_action :set_cart

  def show
    @cart_items = @cart.cart_items.includes(:product)
    @total_price = @cart.total_price
  end

  def add_item
    product = Product.find(params[:product_id])
    if product.present? && current_user.buyer?
      @cart.user = current_user unless @cart.persisted?
      @cart.save! unless @cart.persisted?
      @cart.cart_items.find_or_create_by(product: product) do |item|
        item.quantity = 1
      end
      session[:cart_id] = @cart.id
      flash.now[:notice] = "#{product.name} has been added to your cart."
      render :show
    else
      redirect_to products_path, alert: 'Product not found or you are not authorized to add items to the cart.'
    end
  end

  def remove_item
    item = @cart.cart_items.find_by(product_id: params[:product_id])
    item&.destroy
    redirect_to cart_path(@cart)
  end
end
