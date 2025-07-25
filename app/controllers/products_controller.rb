class ProductsController < ApplicationController
  before_action :authenticate_user!, only: %i[index new create edit update destroy]

  def index
    @products = Product.order(created_at: :desc)
    authorize @products
  end

  def show
    @product = Product.find(params[:id])
    authorize @product
  end

  def new
    @product = Product.new
    @categories = Category.all

    authorize @product
  end

  def create
    @product = Product.new(product_params)
    @product.user = current_user
    authorize @product

    if params[:product][:digital_asset].present?
      # upload to MinIO using ActiveStorage
      @product.digital_asset.attach(params[:product][:digital_asset])

    elsif @product.digital_asset.attached?
      @product.digital_asset.detach
    end

    if @product.save
      if @product.digital_asset.attached? && @product.digital_asset.content_type.start_with?('video/')
        @product.generate_video_thumbnail
      end
      redirect_to @product, notice: 'Product was successfully created.'
    else
      render :new
    end
  end

  def edit
    @product = Product.find(params[:id])
    @categories = Category.all
    authorize @product
  end

  def update
    @product = Product.find(params[:id])
    authorize @product

    @product.digital_asset.detach if @product.digital_asset.attached?

    if @product.update(product_params)
      if @product.digital_asset.attached? && @product.digital_asset.content_type.start_with?('video/')
        VideoThumbnailGenerateJob.perform_async(@product.id)
      end
      redirect_to @product, notice: 'Product was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @product = Product.find(params[:id])
    authorize @product

    if @product.destroy
      redirect_to products_path, notice: 'Product was successfully deleted.'
    else
      redirect_to @product, alert: 'Product could not be deleted.'
    end
  end

  private

  def product_params
    params.require(:product).permit(:name, :description, :price, :category_id, :digital_asset)
  end
end
