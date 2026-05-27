class Users::RegisterUser::ValidateEmptyValue
  include Interactor

  def call
    validate_empty_value(:name)
    validate_empty_value(:email)
    validate_empty_value(:password)
    validate_empty_value(:password_confirmation)
  end

  private

  def validate_empty_value(field)
    if context.send(field).blank?
      context.fail!(message: "#{field.to_s.humanize} cannot be blank")
    end
  end
end
