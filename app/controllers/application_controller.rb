class ApplicationController < ActionController::API
  # ActionController::API não possui helper_method (é exclusivo de views).
  # Devise tenta chamá-lo para registrar current_user, então definimos como no-op.
  def self.helper_method(*_args); end
end
