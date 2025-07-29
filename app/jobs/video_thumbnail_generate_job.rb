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

    # throw an error to test the error handling
    # raise 'Simulated error for testing purposes'

    product.error_message = if product.generate_video_thumbnail
                              nil
                            else
                              'Failed to generate video thumbnail.'
                            end

    product.save
  rescue StandardError => e
    product.error_message = "Failed to generate video thumbnail: #{e.message}"
    product.save
  end
end
