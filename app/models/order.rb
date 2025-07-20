class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, inverse_of: :order
  has_many :payments, inverse_of: :order
  accepts_nested_attributes_for :order_items, allow_destroy: true

  validates :user_id, presence: true
  validates :status, presence: true
  validates :total_price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  attribute :status, :string, default: 'pending'
end
