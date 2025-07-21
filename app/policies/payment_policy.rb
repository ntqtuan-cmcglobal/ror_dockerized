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

  def destroy?
    user.admin?
  end
end
