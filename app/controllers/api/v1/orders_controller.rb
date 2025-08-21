module Api
  module V1
    class OrdersController < ApplicationController
      include Pundit::Authorization
      before_action :doorkeeper_authorize!

      def index
        orders = current_user.orders.order(created_at: :desc)
        authorize orders

        render json: orders
      end

      def show
        order = current_user.orders.find(params[:id])
        authorize order

        render json: order
      end

      def create
        order = current_user.orders.new(order_params)
        authorize order

        products = Product.where(id: order_params[:order_items_attributes].map { |item| item[:product_id] })
        total_price = 0

        order.order_items.each do |order_item|
          # Set quantity to 1 if not provided
          order_item.quantity ||= 1
          product = products.find { |p| p.id == order_item.product_id }
          if product
            order_item.price = product.price
            total_price += product.price * order_item.quantity
          end
        end

        order.total_price = total_price

        if order.save
          @order = order
          render json: order, status: :created
        else
          render json: { errors: order.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      # Find the user that owns the access token
      def current_user
        @current_user ||= User.find_by(id: doorkeeper_token[:resource_owner_id]) if doorkeeper_token
      end

      def order_params
        params.require(:order).permit(order_items_attributes: %i[product_id])
      end
    end
  end
end
