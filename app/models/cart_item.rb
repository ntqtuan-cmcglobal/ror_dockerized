class CartItem < ApplicationRecord
  # Associations
  belongs_to :cart
  belongs_to :product

  # Validations
  validates :product_id, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
end
