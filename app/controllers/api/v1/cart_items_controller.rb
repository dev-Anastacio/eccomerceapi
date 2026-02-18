class Api::V1::CartItemsController < ApplicationController
  before_action :set_cart_item, only: [:destroy, :update]

  def index
    @cart_items = CartItem.all.order(:created_at)
    render json: CartItemSerializer.render(@cart_items), status: :ok
  end

  def create
    result = AddItemToCart.call(
    user_id: current_user.id,
    product_id: params[:product_id],
    quantity: params[:quantity]
  )
  
  if result.success?
    render json: result.cart_item, status: :created
  else
    render json: { error: result.error }, status: :unprocessable_entity
  end
  end

  def update
    if @cart_item.update(cart_item_params)
      render json: @cart_item, status: :ok
    else
      render json: @cart_item.errors.full_messages, status: :unprocessable_entity
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
    params.require(:cart_item).permit(:cart_id, :quantity)
  end
end
