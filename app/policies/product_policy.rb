class ProductPolicy
  attr_reader :user, :product

  def initialize(user, product)
    @user = user
    @product = product
  end

  def index?
    true
  end

  def show?
    # return false unless user.present?
    return false if product.is_draft? || product.have_error?

    true
  end

  def new?
    user.admin? || user.seller?
  end

  def create?
    user.admin? || user.seller?
  end

  def edit?
    return false unless user.present?

    user.admin? || (user.seller? && product.owned_by?(user))
  end

  def update?
    edit?
  end

  def destroy?
    user&.admin? || (user&.seller? && product.owned_by?(user))
  end

  def publish?
    user&.admin? || (user.seller? && product.owned_by?(user) && !product.is_draft?)
  end

  def download?
    user.present? && (user.buyer? || user.seller?) && product.digital_asset.attached? && user.orders.joins(:order_items).where(
      order_items: { product_id: product.id }, status: 'paid'
    ).exists?
  end
end
