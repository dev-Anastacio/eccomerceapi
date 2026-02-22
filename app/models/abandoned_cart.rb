class AbandonedCart < ApplicationRecord
  belongs_to :cart
  belongs_to :user

  # Status possíveis (sintaxe correta para Rails 8)
  enum :status, {
    pending: 'pending',
    notified: 'notified',
    recovered: 'recovered',
    expired: 'expired'
  }, default: 'pending'

  # Validações
  validates :cart_total, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true

    # scopes facilita pesquisas no banco de dados. Exemplo: AbandonedCart.pending_notification para pegar os carrinhos pendentes de notificação.
  scope :pending_notification, -> { where(status: 'pending') }
  scope :notified_recently, -> { where('notified_at > ?', 24.hours.ago) }
  scope :expired, -> { where('created_at < ?', 30.days.ago) }
  scope :high_value, -> { where('cart_total > ?', 1000) }

  # Métodos
  def mark_as_notified!
    update!(
      status: 'notified',
      notified_at: Time.current,
      notification_count: notification_count + 1
    )
  end

  def mark_as_recovered!
    update!(
      status: 'recovered',
      recovered_at: Time.current
    )
  end

  def mark_as_expired!
    update!(status: 'expired')
  end

  def can_notify?
    pending? && notification_count < 3 # Máximo 3 notificações
  end

  def time_since_abandoned
    (Time.current - created_at) / 1.hour
  end
end