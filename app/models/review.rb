class Review < ApplicationRecord
  # Pagination
  paginates_per 10

  # Associations
  belongs_to :product
  belongs_to :user

  # Validations
  validates :rating, presence: true, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 5 }
  validates :comment, presence: true, length: { maximum: 500 }
  validates :user_id, uniqueness: { scope: :product_id, message: 'has already reviewed this product' }

  # Scopes
  scope :recent, -> { order(created_at: :desc) }

  # Callbacks
  after_save :update_product_average_rating
  after_destroy :update_product_average_rating

  private

  def update_product_average_rating
    product.update(average_rating: product.reviews.average(:rating).to_f)
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[comment created_at deleted_at id product_id rating updated_at user_id]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[product user]
  end
end
