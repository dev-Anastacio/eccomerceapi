module Authorizable
  extend ActiveSupport::Concern

  included do
    # Executa antes das ações, exceto index e show
    before_action :require_admin, except: [:index, :show]
  end

  private

  def require_admin
    unless current_user&.admin?
      respond_to do |format|
        format.html do
          redirect_to root_path, alert: "Acesso negado. Apenas administradores podem realizar esta ação."
        end
        format.json do
          render json: { error: "Acesso negado. Apenas administradores." }, status: :forbidden
        end
      end
    end
  end

  # Helper para usar nas views
  def current_user_is_admin?
    current_user&.admin?
  end
  helper_method :current_user_is_admin?
end