class Cart::CheckoutCart::CalculateTotals
  include Interactor

  def call
    cart = context.cart
    total = cart.cart_items.sum { |item| item.product.price * item.quantity }
    context.total = total
  end
end