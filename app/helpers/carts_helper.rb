module CartsHelper
  def init_cart
    @cart = current_user.cart || Cart.create(user: current_user)
    session[:cart_id] = @cart.id if @cart.persisted?
  end

  def fetch_cart
    @cart = Cart.find_by(id: session[:cart_id]) || current_user.cart
    session[:cart_id] ||= @cart.id if @cart.persisted?
  end

  def set_cart
    @cart = Cart.find_or_create_by(id: session[:cart_id])
    session[:cart_id] ||= @cart.id
  end
end
