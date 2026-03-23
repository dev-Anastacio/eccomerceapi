class AddItemToCart::ValidateParams
  include Interactor

  def call
    required = %i[user_id product_id quantity]
    missing = required.select { |key| context.send(key).blank? }

    context.fail!(error: "Parâmetros insuficientes: #{missing.join(', ')}") if missing.any?
    context.fail!(error: "Quantidade deve ser maior que zero.") if context.quantity.to_i <= 0
  end
end