class ProductsController < ApplicationController
  before_action :authenticate_user!, only: %i[index new create edit update destroy]

  def index
    time = Benchmark.measure do
      @q = Product.ransack(params[:q])
      @products = @q.result.page(params[:page]).per(params[:per_page] || 12).order(created_at: :desc)
      @products = @products.includes(:user, :category, digital_asset_attachment: :blob,
                                                       video_thumbnail_attachment: :blob)

      authorize @products
    end
    Rails.logger.info "ProductsController#index took #{time.real} seconds"
  end

  def show
    @product = Product.includes(
      :user,
      :category,
      :reviews,
      digital_asset_attachment: :blob,
      video_thumbnail_attachment: :blob
    ).find(params[:id])

    @reviews = @product
               .reviews
               .order(created_at: :desc)
               .page(params[:page])
               .per(params[:per_page])

    authorize @product
  end

  def new
    @product = Product.new
    @categories = Category.all
    @sellers = User.where(role: 'seller').order(:email)

    authorize @product
  end

  def create
    time = Benchmark.measure do
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
        if @product.digital_asset.attached?
          DigitalAssetDemoGenerateJob.perform_async(@product.id)
          if @product.digital_asset.content_type.start_with?('video/')
            VideoThumbnailGenerateJob.perform_async(@product.id)
          end
        end
        redirect_to @product, notice: 'Product was successfully created.'
      else
        render :new
      end
    end
    Rails.logger.info "ProductsController#create took #{time.real} seconds"
  end

  def edit
    @product = Product.find(params[:id])
    @categories = Category.all
    @sellers = User.where(role: 'seller').order(:email)

    authorize @product
  end

  def update
    @product = Product.find(params[:id])
    authorize @product

    if @product.update(product_params)
      if @product.digital_asset.attached?
        DigitalAssetDemoGenerateJob.perform_async(@product.id)
        if @product.digital_asset.content_type.start_with?('video/')
          VideoThumbnailGenerateJob.perform_async(@product.id)
        end
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

  def download
    @product = Product.find(params[:id])
    authorize @product
    if @product.digital_asset.attached?
      send_data @product.digital_asset.download, filename: @product.digital_asset.filename.to_s,
                                                 type: @product.digital_asset.content_type, disposition: 'attachment'
    else
      redirect_to @product, alert: 'Digital asset not found.'
    end
  end

  def save_review
    @product = Product.find(params[:id])
    pp current_user
    @review = @product.reviews.find_or_initialize_by(user_id: current_user.id)
    @review.assign_attributes(review_params)

    # check policy
    authorize @review

    if @review.save
      redirect_to @product, notice: 'Review was successfully saved.'
    else
      render :show
    end
  end

  def delete_review
    @product = Product.find(params[:id])
    @review = @product.reviews.find_by(user_id: current_user.id)
    if @review.nil?
      redirect_to @product, alert: 'You have not reviewed this product yet.'
    else
      authorize @review
      @review.destroy
      redirect_to @product, notice: 'Review was successfully deleted.'
    end
  end

  def sample_csv
    @products = Product
                .select('products.*, categories.name AS category_name')
                .joins(:category)
                .order('RANDOM()')
                .limit(3)

    csv = CsvService.new

    respond_to do |format|
      format.csv { send_data csv.export(@products, Product::CSV_ATTRIBUTES), filename: "products-#{Date.today}.csv" }
      # any else format throw error
      format.any { head :not_acceptable }
    end
  end

  def bulk_import
    @import_files = ImportFile.visible_to(current_user)
                              .order(created_at: :desc)
                              .page(params[:page])

    authorize @import_files
  end

  def bulk_import_action
    if params[:import_file].present?
      begin
        import_file_record = ImportFile.create(
          user: current_user,
          import_file: params[:import_file],
          status: 'processing'
        )

        ImportCsvFileProductsJob.perform_async(import_file_record.id, current_user.id)

        redirect_to bulk_import_products_path, notice: 'Import products is in processing.'
      rescue StandardError => e
        Rails.logger.error "Failed to import products: #{e.message}"
        redirect_to bulk_import_products_path, alert: "Failed to import products: #{e.message}"
      end
    else
      redirect_to bulk_import_products_path, alert: 'Please upload a valid CSV file.'
    end
  end

  private

  def product_params
    permitted = %i[name description price is_draft category_id digital_asset]
    permitted << :user_id if current_user.admin?
    params.require(:product).permit(permitted)
  end

  def review_params
    params.require(:review).permit(:product_id, :user_id, :rating, :comment)
  end
end
