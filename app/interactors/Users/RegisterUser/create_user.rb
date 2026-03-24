Class Users::RegisterUser::CreateUser
  include Interactor

  def call
    user = User.new(
      name: context.name,
      email: context.email,
      password: context.password,
      password_confirmation: context.password_confirmation
    )

    if user.save
      context.user = user
    else
      context.fail!(message: user.errors.full_messages.to_sentence)
    end
  end

