class Product < ApplicationRecord
  # Pagination
  paginates_per 12

  # CSV Attributes
  CSV_ATTRIBUTES = %w[id name description price category_name].freeze

  # Validations
  validates :name, presence: true, length: { maximum: 100 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Attachments
  has_one_attached :digital_asset
  has_one_attached :digital_asset_demo
  has_one_attached :video_thumbnail

  # Associations
  # has_many :orders, dependent: :destroy
  belongs_to :user
  has_many :cart_items, dependent: :destroy
  has_many :order_items, dependent: :destroy
  has_many :reviews, dependent: :destroy

  belongs_to :category, optional: true

  # Scopes
  def owned_by?(user)
    self.user == user
  end

  def bought_by?(user)
    Order.joins(:order_items)
         .where(order_items: { product_id: id }, user_id: user.id, status: [OrderStatus::PAID, OrderStatus::COMPLETED])
         .exists?
  end

  def have_error?
    error_message.present?
  end

  def generate_video_thumbnail
    return unless digital_asset.attached? && digital_asset.content_type.start_with?('video/')

    video_thumbnail.purge

    puts "Generating thumbnail for video: #{digital_asset.filename}"

    thumb_file = FfmpegService.generate_thumbnail(digital_asset)
    video_thumbnail.attach(io: File.open(thumb_file.path), filename: 'thumbnail.jpg', content_type: 'image/jpeg')
    thumb_file.close
    thumb_file.unlink
  end

  def generate_digital_asset_demo
    return unless digital_asset.attached?

    puts "Generating demo for digital asset: #{digital_asset.filename}"

    # raise StandardError, 'test error message'

    demo_file, content_type, extension = FfmpegService.generate_demo(digital_asset)
    filename = "demo.#{extension}"

    digital_asset_demo.attach(io: File.open(demo_file.path), filename: filename, content_type: content_type)
    demo_file.close
    demo_file.unlink
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[name description price is_draft category_id user_id average_rating created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[category user]
  end
end
