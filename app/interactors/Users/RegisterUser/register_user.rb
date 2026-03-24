class Users::RegisterUser
  include Interactor::Organizer

  organize RegisterUser::ValidateEmptyValue,
           RegisterUser::ValidateUniqueEmail,
           RegisterUser::ValidatePasswordMatch,
           RegisterUser::CreateUser
end