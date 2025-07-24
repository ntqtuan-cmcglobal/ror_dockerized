class ProductPolicy < Struct.new(:user, :product)
  def index?
    user.present?
  end

  def show?
    user.present?
  end

  def new?
    user.admin? || user.seller?
  end

  def create?
    user.admin? || user.seller?
  end

  def edit?
    user.admin? || (user.seller? && product.owned_by?(user))
  end

  def update?
    user.admin? || (user.seller? && product.owned_by?(user))
  end

  def destroy?
    user.admin? || (user.seller? && product.owned_by?(user))
  end
end
