class Cart::CheckoutCart::ClearItems
  include Interactor

  def call
    cart = context.cart
    cart.cart_items.destroy_all
  end
end