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
    end

    def new
      @buyers = User.where(role: 'buyer')
      @order = Order.new
    end

    def create
      @order = Order.new(order_params)
      if @order.save
        redirect_to administration_order_path(@order), notice: 'Order was successfully created.'
      else
        render :new
      end
    end

    def edit
      @order = Order.find(params[:id])
    end

    def update
      @order = Order.find(params[:id])
      if @order.update(order_params)
        redirect_to administration_order_path(@order), notice: 'Order was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @order = Order.find(params[:id])
      @order.destroy
      redirect_to administration_orders_path, notice: 'Order was successfully deleted.'
    end

    private

    def order_params
      params.require(:order).permit(:customer_id, :status, :total_price)
    end
  end
end
