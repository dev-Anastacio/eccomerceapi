module Api
  module V1
    class UserController < ApplicationController
      before_action :set_user, only: [:show, :update, :destroy]

      def index
        @Users = User.all.order(:created_at)
        render json: UserSerializer.render(@Users), status: :ok
      end

      def show
        render json: UserSerializer.render(@User), status: :ok
      end

      def create 
        @Users = User.new(user_params)
        if @Users.save
          render json: @Users, status: :created
        else
          render json: @Users.errors.full_messages, status: :unprocessable_entity
        end
      end

      def update
        if @Users.update(user_params)
          render json: @Users, status: :ok
        else
          render json: @Users.errors.full_messages, status: :unprocessable_entity
        end
      end

      def destroy
        @Users.destroy
        head :no_content
      end

      private 

      def set_user
        @Users = User.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "User not found" }, status: :not_found
      end

      def user_params
        params.require(:user).permit(:name, :email)
      end
    end
  end
end
