class Users::RegisterUser::ValidateUniqueEmail
  include Interactor

  def call
    if User.exists?(email: context.email)
      context.fail!(message: "Email já está em uso.")
    end
  end
end
