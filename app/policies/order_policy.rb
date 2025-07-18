# frozen_string_literal: true

# Policy class for managing authorization on Order records.
class OrderPolicy
  attr_reader :user, :order

  def initialize(user, order)
    @user = user
    @order = order
  end

  def create?
    user.admin? || user.buyer?
  end

  def show?
    user.admin? || (user.buyer? && order.user_id == user.id)
  end

  def index?
    user.admin? || user.buyer?
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
