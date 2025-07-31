module Api
  module V1
    class ProductsController < ApplicationController
      include Pundit::Authorization
      before_action :doorkeeper_authorize!

      def index
        products = Product.includes(:user, :category, digital_asset_attachment: :blob,
                                                      video_thumbnail_attachment: :blob).all

        # Filters
        if params[:filters].present?
          filters = params[:filters]

          products = products.where('name ILIKE ?', "%#{filters[:name]}%") if filters[:name].present?

          if filters[:min_price].present? && filters[:max_price].present?
            products = products.where(price: filters[:min_price]..filters[:max_price])
          elsif filters[:min_price].present?
            products = products.where('price >= ?', filters[:min_price])
          elsif filters[:max_price].present?
            products = products.where('price <= ?', filters[:max_price])
          end

          products = products.where(category_id: filters[:category_id]) if filters[:category_id].present?

          products = products.where(user_id: filters[:user_id]) if filters[:user_id].present?
        end

        # Sorting
        if params[:sort].present?
          sort_column, sort_direction = params[:sort].split(':')
          sort_direction = %w[asc desc].include?(sort_direction) ? sort_direction : 'asc'
          products = products.order("#{sort_column} #{sort_direction}") if Product.column_names.include?(sort_column)
        else
          products = products.order(created_at: :desc)
        end

        @products = products
        authorize @products
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
