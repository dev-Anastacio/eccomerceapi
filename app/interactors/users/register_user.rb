class Users::RegisterUser
  include Interactor::Organizer

  organize Users::RegisterUser::ValidateEmptyValue,
           Users::RegisterUser::ValidateUniqueEmail,
           Users::RegisterUser::ValidatePasswordMatch,
           Users::RegisterUser::CreateUser
end
