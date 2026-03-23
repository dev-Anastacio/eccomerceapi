class AddItemToCart::ValidateStock
  include Interactor

  def call
    return if context.product.stock.nil?

    existente = context.cart.cart_items.find_by(product_id: context.product_id)
    no_carrinho = existente&.quantity.to_i
    total = no_carrinho + context.quantity.to_i

    if total > context.product.stock
      context.fail!(error: "Estoque insuficiente. Disponível: #{context.product.stock}, no carrinho: #{no_carrinho}")
    end
  end
end