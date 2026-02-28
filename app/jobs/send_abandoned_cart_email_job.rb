class SendAbandonedCartEmailJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: 5.minutes, attempts: 3

  def perform(abandoned_cart_id)
    abandoned_cart = AbandonedCart.find_by(id: abandoned_cart_id)

    return unless abandoned_cart
    return unless abandoned_cart.can_notify?

    # Verificar se o carrinho ainda tem itens
    return if abandoned_cart.cart.cart_items.empty?

    Rails.logger.info "📧 Enviando email de recuperação para #{abandoned_cart.user.email}"

    # Enviar email
    AbandonedCartMailer.recovery_email(abandoned_cart).deliver_later

    # Marcar como notificado
    abandoned_cart.mark_as_notified!

    Rails.logger.info "✅ Email enviado com sucesso!"
  rescue => e
    Rails.logger.error "❌ Erro ao enviar email: #{e.message}"
    raise
  end
end