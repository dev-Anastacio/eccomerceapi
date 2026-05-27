class Cart::CheckoutCart::CreateOrder
  include Interactor

  def call
    cart = context.cart
    order = Order.create!(
      user_id: cart.user_id,
      total_amount: context.total,
      status: "pending"
    )

    cart.cart_items.each do |item|
      OrderItem.create!(
        order_id: order.id,
        product_id: item.product_id,
        quantity: item.quantity,
        price: item.product.price
      )
    end

    context.order = order
  end
end
