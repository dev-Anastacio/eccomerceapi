class Cart < ApplicationRecord
  belongs_to :user
  has_many :cart_items, dependent: :destroy
  has_one :abandoned_cart, dependent: :destroy

  def abandoned?
    return false if cart_items.empty?
    
    last_activity = [updated_at, cart_items.maximum(:updated_at)].compact.max
    last_activity < 1.hour.ago
  end

  def total
    cart_items.joins(:product).sum('cart_items.quantity * products.price')
  end

  def mark_as_recovered!
    abandoned_cart&.mark_as_recovered!
  end
end

