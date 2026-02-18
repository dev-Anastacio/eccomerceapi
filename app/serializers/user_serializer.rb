class ProductSerializer < Blueprinter::Base
  identifier :id

  fields :name, :email
  association :Product, blueprint: ProductSerializer
end
