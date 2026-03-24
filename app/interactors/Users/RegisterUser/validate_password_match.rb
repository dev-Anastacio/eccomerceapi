Class Users::RegisterUser::ValidatePasswordMatch
  include Interactor

  def call
    if context.password != context.password_confirmation
      context.fail!(message: "As senhas não coincidem.")
    end
  end