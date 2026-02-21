class ProductSerializer < Blueprinter::Base
  identifier :id
  fields :name, :price, :description, :category, :stock
end