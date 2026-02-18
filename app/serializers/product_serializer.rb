class ProductSerializer < Blueprinter::Base
  identifier :id

  fields :name, :price, :description
  association :User, blueprint: UserSerializer
end
