class AddItemToCart
  include Interactor

  def call
    Rails.logger.info "🛒 Adicionando produto #{context.product_id} ao carrinho do usuário #{context.user_id}"

    validar_parametros
    buscar_carrinho
    verificar_produtos
    validar_estoque
    adicionar_ou_atualizar_item

    Rails.logger.info "✅ Produto adicionado: #{context.cart_item.quantity}x #{context.product.name}"
  rescue => e
    Rails.logger.error "❌ Erro ao adicionar item: #{e.message}"
    context.fail!(error: e.message)
  end

  private

  def validar_parametros
    unless context.user_id && context.product_id && context.quantity
      context.fail!(error: "Parâmetros insuficientes: user_id, product_id e quantity são necessários.")
    end

    if context.quantity.to_i <= 0
      context.fail!(error: "Quantidade deve ser maior que zero.")
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

  def validar_estoque
    return unless context.product.stock # Produtos sem controle de estoque

    quantidade_desejada = context.quantity.to_i
    item_existente = context.cart.cart_items.find_by(product_id: context.product_id)
    quantidade_no_carrinho = item_existente&.quantity || 0
    quantidade_total = quantidade_no_carrinho + quantidade_desejada

    if quantidade_total > context.product.stock
      context.fail!(
        error: "Estoque insuficiente. Disponível: #{context.product.stock}, no carrinho: #{quantidade_no_carrinho}"
      )
    end
  end

  def adicionar_ou_atualizar_item
    context.cart_item = context.cart.cart_items.find_by(product_id: context.product_id)

    if context.cart_item
      nova_quantidade = context.cart_item.quantity + context.quantity.to_i
      context.cart_item.update!(quantity: nova_quantidade)
    else
      context.cart_item = CartItem.create!(
        cart: context.cart,
        product_id: context.product_id,
        quantity: context.quantity.to_i
      )
    end

    # Resetar timer de abandono
    context.cart.touch
  rescue ActiveRecord::RecordInvalid => e
    context.fail!(error: e.message)
  end
end
