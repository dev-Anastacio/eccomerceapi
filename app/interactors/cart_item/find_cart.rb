class CartItem::FindCart
  include Interactor

  def call
    context.cart = Cart.find_by(user_id: context.user_id)
    context.fail!(error: "Carrinho não encontrado para o usuário informado.") unless context.cart
  end
end
