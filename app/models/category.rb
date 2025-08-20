class Category < ApplicationRecord
  # Pagination
  paginates_per 10

  # Validations
  validates :name, presence: true

  # Associations
  has_many :products, dependent: :destroy

  # Returns total number of products
  def total_products
    products.count
  end
end
