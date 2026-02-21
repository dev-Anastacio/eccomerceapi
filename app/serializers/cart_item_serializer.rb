class CartItemSerializer < Blueprinter::Base
  identifier :id
  fields :quantity, :cart_id, :product_id, :created_at, :updated_at
  
  association :product, blueprint: ProductSerializer
  
  field :subtotal do |cart_item|
    cart_item.product.price * cart_item.quantity
  end
end