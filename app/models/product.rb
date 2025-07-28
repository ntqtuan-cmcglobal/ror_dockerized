class Product < ApplicationRecord
  # Validations
  validates :name, presence: true, length: { maximum: 100 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Attachments
  has_one_attached :digital_asset
  has_one_attached :video_thumbnail

  # Associations
  # has_many :orders, dependent: :destroy
  belongs_to :user
  has_many :cart_items, dependent: :destroy
  has_many :order_items, dependent: :destroy

  belongs_to :category, optional: true

  # Scopes
  def owned_by?(user)
    self.user == user
  end

  def is_draft?
    is_draft
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
end
