class OrderItem < ApplicationRecord
  # Pagination
  paginates_per 5

  # Associations
  belongs_to :order, inverse_of: :order_items
  belongs_to :product

  # Validations  validates :order_id, presence: true
  validates :product_id, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :price, numericality: { greater_than_or_equal_to: 0 }
end
