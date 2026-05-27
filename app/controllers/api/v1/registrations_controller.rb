module Api
  module V1
    class RegistrationsController < Devise::RegistrationsController
      respond_to :json

      def create
        result = Users::RegisterUser.call(
          name:                  params[:user][:name],
          email:                 params[:user][:email],
          password:              params[:user][:password],
          password_confirmation: params[:user][:password_confirmation]
        )

        if result.success?
          render json: {
            id:         result.user.id,
            name:       result.user.name,
            email:      result.user.email,
            role:       result.user.role,
            created_at: result.user.created_at
          }, status: :created
        else
          render json: { error: result.message }, status: :unprocessable_entity
        end
      end

      private

      def respond_with(resource, _opts = {})
        if resource.persisted?
          render json: {
            id:         resource.id,
            name:       resource.name,
            email:      resource.email,
            role:       resource.role,
            created_at: resource.created_at
          }, status: :created
        else
          render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
        end
      end
    end
  end
end
