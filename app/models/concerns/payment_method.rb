module PaymentMethod
  PAYMENT_METHODS = {
    credit_card: 'Credit Card',
    stripe: 'Stripe',
    bank_transfer: 'Bank Transfer',
    cash: 'Cash'
  }.freeze

  def self.method_name(method)
    PAYMENT_METHODS[method.to_sym] || 'Unknown Method'
  end
end
