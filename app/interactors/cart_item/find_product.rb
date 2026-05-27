class CartItem::FindProduct
  include Interactor

  def call
    context.product = Product.find_by(id: context.product_id)
    context.fail!(error: "Produto não encontrado.") unless context.product
  end
end
