class OrderItem < ApplicationRecord
  belongs_to :order, inverse_of: :order_items
  belongs_to :product

  # Fields: id, order_id, product_id, quantity, price
  # id: integer, primary key (automatically added by Rails)
  # order_id: integer, foreign key
  # product_id: integer, foreign key
  # quantity: integer
  # price: decimal

  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :price, numericality: { greater_than_or_equal_to: 0 }
end
