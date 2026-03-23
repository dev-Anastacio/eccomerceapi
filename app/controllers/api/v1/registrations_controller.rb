module Api
  module V1
    class RegistrationsController < Devise::RegistrationsController
      respond_to :json

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
