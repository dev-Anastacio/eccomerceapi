class AddItemToCart
  include Interactor

  def call
    validar_parametros
    buscar_carrinho
    verificar_produtos
    adicionar_ou_atualizar_item
  end

  private

  def validar_parametros
    unless context.user_id && context.product_id && context.quantity
      context.fail!(error: "Parâmetros insuficientes: user_id, product_id e quantity são necessários.")
    end
  end

  def buscar_carrinho
    context.cart = Cart.find_by(user_id: context.user_id)
    unless context.cart
      context.fail!(error: "Carrinho não encontrado para o usuário informado.")
    end
  end

  def verificar_produtos
    context.product = Product.find_by(id: context.product_id)
    unless context.product
      context.fail!(error: "Produto não encontrado.")
    end
  end

  def adicionar_ou_atualizar_item
    # Busca item existente do mesmo produto no carrinho
    context.cart_item = context.cart.cart_items.find_by(product_id: context.product_id)
    
    if context.cart_item
      # Atualiza quantidade do item existente
      nova_quantidade = context.cart_item.quantity + context.quantity.to_i
      context.cart_item.update!(quantity: nova_quantidade)
    else
      # Cria novo item
      context.cart_item = CartItem.create!(
        cart: context.cart, 
        product_id: context.product_id, 
        quantity: context.quantity.to_i
      )
    end
  rescue ActiveRecord::RecordInvalid => e
    context.fail!(error: e.message)
  end
end