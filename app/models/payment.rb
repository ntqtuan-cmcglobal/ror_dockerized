class Payment < ApplicationRecord
  # Custom fields
  attr_accessor :stripe_checkout_url

  # Pagination
  paginates_per 10

  # Associations
  belongs_to :order, optional: true

  # Validations
  validates :result, presence: true

  before_create :set_default_result
  after_create :order_payment_process
  after_update :order_payment_process

  private

  def set_default_result
    self.result ||= 'success' if payment_method == 'bank_transfer'

    self.result ||= 'undefined'
  end

  def order_payment_process
    # Disable other payments of this order if any payment result is success
    return unless result == PaymentResult::SUCCESS

    if order.status == OrderStatus::UNPAID
      order.status = OrderStatus::PAID
      order.save(validate: false)
    end

    order.payments.where.not(id: id).each do |payment|
      payment.update!(result: PaymentResult::DISABLED)
    end
  end

  # Scopes
  scope :recent, -> { order(created_at: :desc) }

  # Ransack configuration
  def order_user_full_name
    order&.user&.full_name
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[result payment_method created_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[order user]
  end
end
