class Review < ApplicationRecord
  # Associations
  belongs_to :product
  belongs_to :user

  # Validations
  validates :rating, presence: true, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 5 }
  validates :comment, presence: true, length: { maximum: 500 }
  validates :user_id, uniqueness: { scope: :product_id, message: 'has already reviewed this product' }

  after_save :update_product_average_rating
  after_destroy :update_product_average_rating

  private

  def update_product_average_rating
    product.update(average_rating: product.reviews.average(:rating).to_f)
  end
end
