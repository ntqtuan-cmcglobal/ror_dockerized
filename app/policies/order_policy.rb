# frozen_string_literal: true

# Policy class for managing authorization on Order records.
class OrderPolicy
  attr_reader :user, :order

  def initialize(user, order)
    @user = user
    @order = order
  end

  def create?
    true unless user.seller?
  end

  def edit?
    true if user.admin?
  end

  def update?
    true if user.admin?
  end

  def new?
    true if user.admin?
  end

  def show?
    user.admin? || (user.seller? && order.get_seller.include?(user)) || (user.buyer? && order.user_id == user.id)
  end

  def index?
    user.admin? || user.buyer?
  end

  def cancel_order?
    return false unless can_attempt_cancel?

    return true if admin_can_cancel?
    return true if buyer_can_cancel?
    return true if seller_can_cancel?

    false
  end

  def destroy?
    user.admin?
  end

  private

  def can_attempt_cancel?
    user.admin? || user.buyer? || user.seller?
  end

  def active?
    ![OrderStatus::COMPLETED, OrderStatus::CANCELLED].include?(order.status)
  end

  def admin_can_cancel?
    user.admin? && active?
  end

  def buyer_can_cancel?
    user.buyer? && order.user_id == user.id && active?
  end

  def seller_can_cancel?
    user.seller? && order.order_items.any? { |item| item.product.user_id == user.id } && active?
  end

  # Scope class for limiting the records visible to the user.
  class Scope < ApplicationPolicy::Scope
    def resolve
      # Adjust this logic as needed for your app's requirements
      if user.admin?
        scope.all
      else
        scope.where(user_id: user.id)
      end
    end
  end
end
