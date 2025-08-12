module Administration
  class OrdersController < ApplicationController
    before_action :authenticate_user!
    def index
      @q = Order.ransack(params[:q])
      @orders = @q.result.page(params[:page]).order(created_at: :desc)
      authorize @orders
    end

    def show
      @order = Order.find(params[:id])
      authorize @order
    end

    def new
      @buyers = User.where(role: 'buyer')
      @order = Order.new
      authorize @order
    end

    def create
      @order = build_order_from_params
      authorize @order

      ActiveRecord::Base.transaction do
        @order.save!
        # create_order_items(@order, params[:order][:product_ids])
        redirect_to administration_order_path(@order), notice: 'Order was successfully created.'
      end
    rescue ActiveRecord::Rollback, ActiveRecord::RecordInvalid => e
      handle_create_order_failure(e)
    end

    def edit
      @order = Order.find(params[:id])
      @buyers = User.where(role: 'buyer')
      authorize @order
    end

    def update
      @order = Order.find(params[:id])
      authorize @order

      update_order_with_transaction(@order, params[:order])
    rescue ActiveRecord::Rollback, ActiveRecord::RecordInvalid => e
      flash[:alert] = "Failed to update order. #{e.message}"
      @buyers = User.where(role: 'buyer')
      render :edit
    end

    def destroy
      @order = Order.find(params[:id])
      authorize @order
      ActiveRecord::Base.transaction do
        @order.order_items.destroy_all
        @order.destroy
      end
      redirect_to administration_orders_path, notice: 'Order was successfully deleted.'
    end

    private

    def handle_create_order_failure(error = nil)
      flash[:alert] = "Failed to create order. #{error&.message}"
      @buyers = User.where(role: 'buyer')
      @order = Order.new
      render :new
    end

    def build_order_from_params
      total_price = Product.where(id: params[:order][:product_ids]).sum(:price)
      order = Order.build(user_id: params[:order][:user_id], status: 'pending', total_price: total_price)
      order.order_items.build(order_items_attributes(params[:order][:product_ids]))
      order
    end

    def order_items_attributes(product_ids)
      Product.where(id: product_ids).map do |product|
        { product_id: product.id, quantity: 1, price: product.price }
      end
    end

    def update_order_with_transaction(order, order_params)
      ActiveRecord::Base.transaction do
        order.assign_attributes(
          user_id: order_params[:user_id],
          total_price: Product.where(id: order_params[:product_ids]).sum(:price)
        )
        order.order_items.destroy_all
        order.order_items.build(order_items_attributes(order_params[:product_ids]))
        order.save!
        redirect_to administration_order_path(order), notice: 'Order was successfully updated.'
      end
    end

    def order_params
      params.require(:order).permit(:user_id, :product_ids)
    end
  end
end
