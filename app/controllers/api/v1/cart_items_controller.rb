module Api
  module V1
    class CartItemsController < ApplicationController
      before_action :set_cart_item, only: [:show, :update, :destroy]

      def index
        @cart_items = CartItem.all.includes(:product)
        render json: CartItemSerializer.render(@cart_items), status: :ok
      end

      def show
        render json: CartItemSerializer.render(@cart_item), status: :ok
      end

      def create
        @cart = Cart.find(params[:cart_id])
        @cart_item = @cart.cart_items.build(cart_item_params)

        if @cart_item.save
          render json: CartItemSerializer.render(@cart_item), status: :created
        else
          render json: { errors: @cart_item.errors.full_messages }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Cart not found" }, status: :not_found
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

      def set_cart_item
        @cart_item = CartItem.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Cart item not found" }, status: :not_found
      end

      def cart_item_params
        params.require(:cart_item).permit(:product_id, :quantity)
      end
    end
  end
end