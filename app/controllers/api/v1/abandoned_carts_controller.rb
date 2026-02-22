module Api
  module V1
    class AbandonedCartsController < ApplicationController
      def index
        @abandoned_carts = AbandonedCart.includes(:user, cart: :cart_items).order(created_at: :desc).limit(50)
        
        render json: @abandoned_carts.as_json(
          include: {
            user: { only: [:id, :name, :email] },
            cart: {
              include: {
                cart_items: {
                  include: {
                    product: { only: [:id, :name, :price] }
                  }
                }
              }
            }
          }
        )
      end

      def show
        @abandoned_cart = AbandonedCart.find(params[:id])
        render json: @abandoned_cart.as_json(
          include: {
            user: { only: [:id, :name, :email] },
            cart: {
              include: {
                cart_items: {
                  include: {
                    product: { only: [:id, :name, :price] }
                  }
                }
              }
            }
          }
        )
      end

      def recover
        @abandoned_cart = AbandonedCart.find(params[:id])
        @abandoned_cart.mark_as_recovered!
        
        render json: { 
          message: "Carrinho marcado como recuperado!",
          abandoned_cart: @abandoned_cart 
        }
      end

      def stats
        stats = {
          total_abandoned: AbandonedCart.count,
          pending: AbandonedCart.pending.count,
          notified: AbandonedCart.notified.count,
          recovered: AbandonedCart.recovered.count,
          expired: AbandonedCart.expired.count,
          total_value_abandoned: AbandonedCart.pending.sum(:cart_total),
          total_value_recovered: AbandonedCart.recovered.sum(:cart_total),
          recovery_rate: calculate_recovery_rate,
          average_cart_value: AbandonedCart.average(:cart_total).to_f.round(2)
        }

        render json: stats
      end

      private

      def calculate_recovery_rate
        total = AbandonedCart.where(status: ['recovered', 'notified']).count
        return 0 if total.zero?
        
        recovered = AbandonedCart.recovered.count
        ((recovered.to_f / total) * 100).round(2)
      end
    end
  end
end