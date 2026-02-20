class AddItemToCart
  include Interactor

  def call
    buscar_ou_criar_carrinho
    verificar_item_existente
    adicionar_ou_atualizar_item
  end

  private

  def buscar_ou_criar_carrinho
    context.cart = Cart.find_or_create_by(user_id: context.user_id)
  end

  def verificar_item_existente
    context.cart_item = context.cart.cart_items.find_by(product_id: context.product_id)
  end

  def adicionar_ou_atualizar_item
    if context.cart_item
      context.cart_item.update(quantity: context.cart_item.quantity + context.quantity)
    else
      context.cart_item = CartItem.create!(cart: context.cart, product_id: context.product_id, quantity: context.quantity)
    end
  end
end
