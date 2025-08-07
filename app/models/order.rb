class Order < ApplicationRecord
  # Pagination
  paginates_per 5

  # Validations
  validates :user_id, presence: true
  validates :status, presence: true
  validates :total_price, presence: true, numericality: { greater_than_or_equal_to: 0 }

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
  def total_items
    order_items.sum(:quantity)
  end

  def total_price_with_currency
    "$#{total_price}"
  end
end
