module Api
  module V1
    class SessionsController < Devise::SessionsController
      respond_to :json

      def create
        self.resource = warden.authenticate!(auth_options)
        sign_in(resource_name, resource, store: false)

        render json: {
          id: resource.id,
          name: resource.name,
          email: resource.email,
          role: resource.role
        }, status: :ok
      end

      def destroy
        sign_out(resource_name)
        render json: { message: "Logout realizado com sucesso." }, status: :ok
      end
    end
  end
end
