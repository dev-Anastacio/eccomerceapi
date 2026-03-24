module Api
  module V1
    class CartItemsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_cart
      before_action :set_cart_item, only: [:show, :update, :destroy]

      def index
        cart_items = @cart.cart_items.includes(:product)
        render json: CartItemSerializer.render(cart_items), status: :ok
      end

      def show
        render json: CartItemSerializer.render(@cart_item), status: :ok
      end

      def create
        result = CartItem::AddItemToCart.call(
          user_id: current_user.id,
          product_id: cart_item_params[:product_id],
          quantity: cart_item_params[:quantity]
        )

        if result.success?
          render json: CartItemSerializer.render(result.cart_item), status: :created
        else
          render json: { error: result.error }, status: :unprocessable_entity
        end
      end

      def update
        if @cart_item.update(cart_item_params)
          render json: CartItemSerializer.render(@cart_item), status: :ok
        else
          render json: { errors: @cart_item.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @cart_item.destroy
        head :no_content
      end

      private

      def set_cart
        @cart = current_user.cart || current_user.create_cart
      end

      def set_cart_item
        @cart_item = @cart.cart_items.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Cart item not found" }, status: :not_found
      end

      def cart_item_params
        params.require(:cart_item).permit(:product_id, :quantity)
      end
    end
  end
end