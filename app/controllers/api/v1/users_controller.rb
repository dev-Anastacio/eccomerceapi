module Api
  module V1
    class UsersController < ApplicationController
      before_action :set_user, only: [:show, :update, :destroy]

      def index
        @users = User.all.order(:created_at)
        render json: UserSerializer.render(@users), status: :ok
      end

      def show
        render json: UserSerializer.render(@user), status: :ok
      end

      def create 
        @user = User.new(user_params)
        if @user.save
          render json: UserSerializer.render(@user), status: :created
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @user.update(user_params)
          render json: UserSerializer.render(@user), status: :ok
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @user.destroy
        head :no_content
      end

      private 

      def set_user
        @user = User.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "User not found" }, status: :not_found
      end

      def user_params
        params.require(:user).permit(:name, :email, :password, :password_confirmation, :address)
      end
    end
  end
end