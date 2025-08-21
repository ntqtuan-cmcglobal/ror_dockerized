class Order < ApplicationRecord
  # Pagination
  paginates_per 10

  # Validations
  validates :user_id, presence: true
  validates :status, presence: true
  validates :total_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :order_items, presence: true
  validate :contains_previously_ordered_product

  # Associations
  belongs_to :user
  has_many :order_items, inverse_of: :order
  has_many :payments, inverse_of: :order
  accepts_nested_attributes_for :order_items, allow_destroy: true

  validates :user_id, presence: true
  validates :status, presence: true
  validates :total_price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  attribute :status, :string, default: 'unpaid'

  # Ransack
  def self.ransackable_attributes(auth_object = nil)
    %w[id user_id status total_price created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[user order_items payments]
  end

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :unpaid, -> { where(status: 'unpaid') }
  scope :paid, -> { where(status: 'paid') }
  scope :completed, -> { where(status: 'completed') }

  # Instance methods
  def get_seller
    order_items.map(&:product).map(&:user).uniq
  end

  def total_items
    order_items.sum(:quantity)
  end

  def total_price_with_currency
    "$#{total_price}"
  end

  def contains_previously_ordered_product
    product_ids_in_new_order = order_items.map(&:product_id)
    # Find all non-cancelled orders of this user
    previous_orders = Order.where(user_id: user_id).where.not(status: OrderStatus::CANCELLED)
    previous_order_items = OrderItem.where(order_id: previous_orders.select(:id))

    # Find duplicated product_ids
    duplicated_product_ids = product_ids_in_new_order & previous_order_items.pluck(:product_id)

    # Find the order_id(s) that contain duplicated products
    duplicated_order_ids = previous_order_items.where(product_id: duplicated_product_ids).pluck(:order_id).uniq

    return if duplicated_order_ids.empty?

    errors.add(:base,
               "There's one or more products owned. Check <a class='text-blue-600 underline' target='_blank' href='/orders/#{duplicated_order_ids.first}'>this</a> order for more details.".html_safe)
  end
end
