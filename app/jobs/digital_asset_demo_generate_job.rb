require 'sidekiq'

class DigitalAssetDemoGenerateJob
  include Sidekiq::Worker
  sidekiq_options queue: 'digital_asset_demo_generate', retry: false

  def perform(product_id)
    product = Product.find(product_id)

    # clear error message before generating demo
    product.error_message = nil
    product.save

    product.generate_digital_asset_demo if product.digital_asset.attached?
  rescue StandardError => e
    product.error_message = e.message
    product.save
  end
end
