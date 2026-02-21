class UserSerializer < Blueprinter::Base
  identifier :id
  fields :name, :email, :address
end