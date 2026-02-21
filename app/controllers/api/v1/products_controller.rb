module Api
  module V1
    class ProductsController < ApplicationController 
      before_action :set_product , only: [:show, :update, :destroy]
      
      def index
        @products = Product.all.order(:created_at) 
        render json: ProductSerializer.render(@products), status: :ok
      end

      def show
        render json: ProductSerializer.render(@product), status: :ok
      end

      def create
        @product = Product.new(product_params)
        if @product.save
          render json: @product, status: :created
        else
          render json: @product.errors.full_messages, status: :unprocessable_entity
        end
      end

      def update
        if @product.update(product_params)
          render json: @product, status: :ok
        else
          render json: @product.errors.full_messages, status: :unprocessable_entity
        end
      end

      def destroy
        @product.destroy
        head :no_content
      end

      private 

      def set_product
        @product = Product.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Product not found" }, status: :not_found
      end

      def product_params
        params.require(:product).permit(:name, :price, :description)
      end
    end
  end
end
