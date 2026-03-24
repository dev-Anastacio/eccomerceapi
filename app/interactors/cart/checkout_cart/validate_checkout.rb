class Cart::CheckoutCart::ValidateCheckout
  include Interactor

  def call
    cart = context.cart
    if cart.cart_items.empty?
      context.fail!(error: "O carrinho está vazio. Adicione itens antes de finalizar a compra.")
    end

    cart.cart_items.each do |item|
      unless item.product.stock.to_i >= item.quantity
        context.fail!(error: "Produto #{item.product.name} não tem estoque suficiente para a quantidade solicitada.")
      end
    end
  end
end