module Api
  module V1
    class AbandonedCartsController < ApplicationController
      before_action :authenticate_user!
      before_action :require_admin
      before_action :set_abandoned_cart, only: [:show, :recover]

      def index
        @abandoned_carts = AbandonedCart
          .includes(:user, cart: { cart_items: :product })
          .order(created_at: :desc)
          .limit(50)

        render json: @abandoned_carts.as_json(
          include: {
            user: { only: [:id, :name, :email] },
            cart: {
              include: {
                cart_items: {
                  include: { product: { only: [:id, :name, :price] } }
                }
              }
            }
          }
        )
      end

      def show
        render json: @abandoned_cart.as_json(
          include: {
            user: { only: [:id, :name, :email] },
            cart: {
              include: {
                cart_items: {
                  include: { product: { only: [:id, :name, :price] } }
                }
              }
            }
          }
        )
      end

      def recover
        if @abandoned_cart.recovered?
          return render json: { error: "Carrinho já foi recuperado." }, status: :unprocessable_entity
        end

        if @abandoned_cart.expired?
          return render json: { error: "Carrinho expirado, não pode ser recuperado." }, status: :unprocessable_entity
        end

        @abandoned_cart.mark_as_recovered!
        render json: {
          message: "Carrinho marcado como recuperado!",
          abandoned_cart: @abandoned_cart
        }
      end

      def stats
        render json: AbandonedCart.statistics
      end

      private

      def set_abandoned_cart
        @abandoned_cart = AbandonedCart.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Carrinho abandonado não encontrado." }, status: :not_found
      end

      def require_admin
        unless current_user&.admin?
          render json: { error: "Acesso negado. Apenas admins." }, status: :forbidden
        end
      end
    end
  end
end
