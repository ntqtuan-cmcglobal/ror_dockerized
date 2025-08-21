class PaymentPolicy
  attr_reader :user, :payment

  def initialize(user, payment)
    @user = user
    @payment = payment
  end

  def show?
    user.admin? || payment.user_id == user.id
  end

  def new?
    user.present? && user.buyer? && payment.order.user_id == user.id
  end

  def create?
    user.present?
  end

  def update?
    user.admin? || payment.user_id == user.id
  end

  def mark_as_paid?
    return false unless payment.result == PaymentResult::PENDING && payment.payment_method == 'bank_transfer'

    payment_order_items = payment.order.order_items
    is_current_user_product = payment_order_items.any? { |item| item.product.user_id == user.id }

    user.admin? || is_current_user_product
  end

  def destroy?
    user.admin?
  end
end
