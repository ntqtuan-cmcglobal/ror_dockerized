module Api
  module V1
    class ProductsController < ApplicationController
      include Pundit::Authorization
      before_action :doorkeeper_authorize!

      def index
        @products = Product.all.order(created_at: :desc)
        authorize @products
        # The corresponding jbuilder view will be rendered automatically
      end

      def show
        @product = Product.find(params[:id])
        authorize @product
      end

      private

      # Find the user that owns the access token
      def current_user
        @current_user ||= User.find_by(id: doorkeeper_token[:resource_owner_id]) if doorkeeper_token
      end
    end
  end
end
