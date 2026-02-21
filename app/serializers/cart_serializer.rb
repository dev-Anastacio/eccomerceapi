class CartSerializer < Blueprinter::Base
  identifier :id
  fields :user_id, :created_at, :updated_at

  view :with_items do
    association :cart_items, blueprint: CartItemSerializer do |cart|
      cart.cart_items.includes(:product)
    end
    
    field :total do |cart|
      cart.cart_items.joins(:product).sum('products.price * cart_items.quantity')
    end
  end
end