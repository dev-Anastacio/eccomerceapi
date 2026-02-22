# Use this file to easily define all of your cron jobs.
set :output, 'log/cron.log'

# Verificar carrinhos abandonados a cada hora
every 1.hour do
  runner "CheckAbandonedCartsJob.perform_later"
end

# Expirar carrinhos antigos (diariamente às 3h)
every 1.day, at: '3:00 am' do
  runner "AbandonedCart.where('created_at < ?', 30.days.ago).update_all(status: 'expired')"
end