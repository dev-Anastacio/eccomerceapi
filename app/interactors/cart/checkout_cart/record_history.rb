class Cart::CheckoutCart::RecordHistory
  include Interactor

  def call
    cart = context.cart
    user_id = cart.user_id
    total = context.total

    CartHistory.create!(
      user_id: user_id,
      total: total,
      checkout_date: Time.current
    )
  end
end
