require 'sidekiq'

class VideoThumbnailGenerateJob
  include Sidekiq::Worker
  sidekiq_options queue: 'video_thumbnail_generation', retry: false

  # This job is responsible for generating video thumbnails asynchronously
  # It checks if the product has a digital asset attached and if it's a video
  # If so, it calls the method to generate the thumbnail

  def perform(product_id)
    product = Product.find(product_id)
    return unless product.digital_asset.attached? && product.digital_asset.content_type.start_with?('video/')

    # clear error message before generating thumbnail
    product.error_message = nil
    product.save

    product.generate_video_thumbnail
  rescue StandardError => e
    product.error_message = e.message
    product.save
  end
end
