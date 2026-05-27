class CartItem::TouchCart
  include Interactor

  def call
    context.cart.touch
  end
end
