class CategoryPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    user.present?
  end

  def new?
    user.present? && user.admin?
  end

  def create?
    user.present? && user.admin?
  end

  def edit?
    user.present? && user.admin?
  end

  def update?
    user.present? && user.admin? == user
  end

  def destroy?
    user.present? && user.admin?
  end
end
