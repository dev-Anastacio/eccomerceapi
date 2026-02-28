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
  validates :status, presence: true, inclusion: { in: statuses.keys }
  validates :notification_count, numericality: { greater_than_or_equal_to: 0, only_integer: true }, allow_nil: true

  # Scopes para cada status (CORRIGIDO)
  scope :pending, -> { where(status: 'pending') }
  scope :notified, -> { where(status: 'notified') }
  scope :recovered, -> { where(status: 'recovered') }
  scope :expired, -> { where(status: 'expired') }

  # Scopes adicionais
  scope :pending_notification, -> { where(status: 'pending') }
  scope :notified_recently, -> { where('notified_at > ?', 24.hours.ago) }
  scope :old, -> { where('created_at < ?', 30.days.ago) }
  scope :high_value, -> { where('cart_total > ?', 1000) }
  scope :can_send_reminder, -> { 
    where(status: 'notified')
      .where('notified_at < ?', 24.hours.ago)
      .where('notification_count < ?', 3)
  }

  # Callbacks (CORRIGIDO: apenas em updates)
  before_update :check_expiration

  # Métodos de mudança de status
  def mark_as_notified!
    update!(
      status: 'notified',
      notified_at: Time.current,
      notification_count: (notification_count || 0) + 1
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

  # Métodos de verificação
  def can_notify?
    pending? && (notification_count || 0) < 3
  end

  def can_expire?
    # CORRIGIDO: Verificar se created_at existe antes
    return false unless created_at
    created_at < 30.days.ago && !expired? && !recovered?
  end

  def should_send_reminder?
    notified? && 
    notified_at && 
    notified_at < 24.hours.ago && 
    (notification_count || 0) < 3
  end

  # Métodos de informação
  def time_since_abandoned
    return 0 unless created_at
    (Time.current - created_at) / 1.hour
  end

  def items_count
    cart&.cart_items&.count || 0
  end

  def cart_summary
    {
      id: id,
      user_name: user.name,
      user_email: user.email,
      total: cart_total,
      items: items_count,
      status: status,
      hours_since_abandoned: time_since_abandoned.round(1),
      notifications_sent: notification_count || 0,
      last_notified: notified_at&.strftime('%d/%m/%Y %H:%M')
    }
  end

  # Método de classe para estatísticas
  def self.statistics
    total_count = count
    notified_count = notified.count
    
    {
      total: total_count,
      pending: pending.count,
      notified: notified_count,
      recovered: recovered.count,
      expired: expired.count,
      high_value: high_value.count,
      average_total: total_count > 0 ? average(:cart_total).to_f.round(2) : 0,
      recovery_rate: notified_count > 0 ? (recovered.count.to_f / notified_count * 100).round(2) : 0
    }
  end

  private

  def check_expiration
    if can_expire?
      self.status = 'expired'
    end
  end
end
