class CheckAbandonedCartsJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "🔍 Verificando carrinhos abandonados..."

    carts_checked = 0
    carts_marked = 0

    # Buscar carrinhos com itens que não foram atualizados há mais de 1 hora
    Cart.joins(:cart_items)
        .where('carts.updated_at < ?', 1.hour.ago)
        .distinct
        .find_each do |cart|
      
      carts_checked += 1

      # Verificar se já não tem um registro de abandono pendente
      next if cart.abandoned_cart&.pending? || cart.abandoned_cart&.notified?

      # Calcular total do carrinho
      total = cart.total

      # Só processar carrinhos com valor > 0
      next if total <= 0

      # Criar registro de carrinho abandonado
      abandoned_cart = AbandonedCart.create!(
        cart: cart,
        user: cart.user,
        cart_total: total,
        status: 'pending'
      )

      # Agendar envio de email para daqui a 5 minutos
      SendAbandonedCartEmailJob.set(wait: 5.minutes).perform_later(abandoned_cart.id)

      carts_marked += 1
      Rails.logger.info "📧 Carrinho #{cart.id} marcado como abandonado (Total: R$ #{total})"
    end

    Rails.logger.info "✅ Verificação concluída: #{carts_checked} carrinhos verificados, #{carts_marked} marcados como abandonados"
  end
end