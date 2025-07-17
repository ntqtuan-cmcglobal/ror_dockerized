class CartPolicy
  attr_reader :user, :cart

  def initialize(user, cart)
    @user = user
    @cart = cart
  end

  def show?
    buyer?
  end

  def update?
    buyer?
  end

  def destroy?
    buyer?
  end

  def add_item?
    buyer? && cart.user == user
  end

  def remove_item?
    buyer? && cart.user == user
  end

  private

  def buyer?
    user&.role == 'buyer'
  end
end
