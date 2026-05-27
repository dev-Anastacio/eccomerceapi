module Api
  module V1
    class CartsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_user

      def show
        @cart = @user.cart || @user.create_cart
        render json: CartSerializer.render(@cart, view: :with_items), status: :ok
      end

      def checkout
        cart = @user.cart || @user.create_cart

        result = Cart::CheckoutCart.call(cart: cart)

        if result.success?
          render json: {
            message: "Checkout realizado com sucesso",
            order_id: result.order.id,
            total: result.total,
            status: result.order.status
          }, status: :created
        else
          render json: { error: result.error }, status: :unprocessable_entity
        end
      end

      private

      def set_user
        @user = current_user
      end
    end
  end
end
