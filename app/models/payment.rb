class Payment < ApplicationRecord
  # Custom fields
  attr_accessor :stripe_checkout_url

  # Associations
  belongs_to :user, optional: true
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
end
