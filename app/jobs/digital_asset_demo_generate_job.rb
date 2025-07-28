require 'sidekiq'

class DigitalAssetDemoGenerateJob
  include Sidekiq::Worker
  sidekiq_options queue: 'digital_asset_demo_generate', retry: false

  def perform(product_id)
    product = Product.find(product_id)
    product.generate_digital_asset_demo if product.digital_asset.attached?
  rescue StandardError => e
    Rails.logger.error "Failed to generate digital asset demo for product #{product_id}: #{e.message}"
  end
end
