class Cart::CheckoutCart::ReserveInventory
  include Interactor

  def call
    cart = context.cart
    cart.cart_items.each do |item|
      product = item.product
      if product.stock.to_i >= item.quantity
        product.update!(stock: product.stock.to_i - item.quantity)
      else
        context.fail!(error: "Produto #{product.name} não tem estoque suficiente para a quantidade solicitada.")
      end
    end
  end
end
