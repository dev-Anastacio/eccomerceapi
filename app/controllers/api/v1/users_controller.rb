module Api
  module V1
    class UsersController < ApplicationController
      before_action :authenticate_user!
      before_action :set_user, only: [ :show, :update, :destroy ]

      def index
        authorize_admin!
        @users = User.all.order(:created_at)
        render json: UserSerializer.render(@users), status: :ok
      end

      def show
        authorize_self_or_admin!
        render json: UserSerializer.render(@user), status: :ok
      end

      def update
        authorize_self_or_admin!
        if @user.update(user_params)
          render json: UserSerializer.render(@user), status: :ok
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        authorize_self_or_admin!
        @user.destroy
        render json: { message: "Usuário removido com sucesso." }, status: :ok
      end

      private

      def set_user
        @user = User.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Usuário não encontrado." }, status: :not_found
      end

      def user_params
        params.require(:user).permit(:name, :address)
      end

      def authorize_admin!
        unless current_user&.admin?
          render json: { error: "Acesso negado. Apenas admins." }, status: :forbidden
        end
      end

      def authorize_self_or_admin!
        unless current_user&.admin? || current_user&.id == @user.id
          render json: { error: "Acesso negado." }, status: :forbidden
        end
      end
    end
  end
end
