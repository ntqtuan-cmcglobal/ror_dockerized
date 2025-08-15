# frozen_string_literal: true

# PaymentMethod provides constants and helper methods for supported payment methods.
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

  # Returns an array suitable for options_for_select in forms.
  def self.options_for_select
    PAYMENT_METHODS.map { |key, value| [value, key] }
  end
end
