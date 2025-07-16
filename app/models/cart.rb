class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  belongs_to :user

  def total_price
    cart_items.includes(:product).sum('price * quantity')
  end
end
