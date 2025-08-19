# frozen_string_literal: true

module Api
  module V1
    # Controller for managing products in the API.
    # Provides endpoints for listing and showing products with filtering, sorting, and pagination.
    class ProductsController < ApplicationController
      include Pundit::Authorization
      before_action :doorkeeper_authorize!

      def index
        products = Product.includes(:user, :category, digital_asset_attachment: :blob,
                                                      video_thumbnail_attachment: :blob).all

        products = apply_filters(products)
        products = apply_sort(products)
        products = apply_pagination(products)

        @products = products
        @pagination = {
          current_page: @products.current_page,
          next_page: @products.next_page,
          prev_page: @products.prev_page,
          total_pages: @products.total_pages,
          total_count: @products.total_count
        }
        authorize @products
      end

      def show
        @product = Product.find(params[:id])
        authorize @product
      end

      private

      # Applies filtering to the products relation based on params.
      def apply_filters(products)
        return products unless params[:filters].present?

        filters = params[:filters]

        if filters[:name].present?
          products = products.where('name ILIKE ?', "%#{ActiveRecord::Base.sanitize_sql_like(filters[:name])}%")
        end

        if filters[:min_price].present? && filters[:max_price].present?
          products = products.where(price: filters[:min_price]..filters[:max_price])
        elsif filters[:min_price].present?
          products = products.where('price >= ?', filters[:min_price])
        elsif filters[:max_price].present?
          products = products.where('price <= ?', filters[:max_price])
        end

        products = products.where(category_id: filters[:category_id]) if filters[:category_id].present?

        products = products.where(user_id: filters[:user_id]) if filters[:user_id].present?

        products
      end

      # Applies sorting to the products relation based on params.
      def apply_sort(products)
        if params[:sort].present?
          sort_column, sort_direction = params[:sort].split(':')
          sort_direction = %w[asc desc].include?(sort_direction) ? sort_direction : 'asc'
          if Product.column_names.include?(sort_column)
            products = products.order(Arel.sql("#{sort_column} #{sort_direction}"))
          end
        else
          products = products.order(created_at: :desc)
        end
        products
      end

      # Applies pagination to the products relation based on params.
      def apply_pagination(products)
        page = params[:page].to_i.positive? ? params[:page].to_i : 1
        per_page = params[:per_page].to_i.positive? ? params[:per_page].to_i : 10
        products.page(page).per(per_page)
      end

      # Find the user that owns the access token
      def current_user
        @current_user ||= User.find_by(id: doorkeeper_token[:resource_owner_id]) if doorkeeper_token
      end
    end
  end
end
