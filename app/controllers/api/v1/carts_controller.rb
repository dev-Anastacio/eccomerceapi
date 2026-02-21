module Api
  module V1
    class CartsController < ApplicationController
      before_action :set_user

      def show
        @cart = @user.cart || @user.create_cart
        render json: CartSerializer.render(@cart, view: :with_items), status: :ok
      end

      private

      def set_user
        @user = User.find(params[:user_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "User not found" }, status: :not_found
      end
    end
  end
end