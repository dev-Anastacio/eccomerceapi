class AbandonedCartMailer < ApplicationMailer
  default from: "noreply@eccomerce.com"

  def recovery_email(abandoned_cart)
    @abandoned_cart = abandoned_cart
    @user           = abandoned_cart.user
    @cart           = abandoned_cart.cart
    @cart_items     = @cart.cart_items.includes(:product)
    @total          = abandoned_cart.cart_total

    @recovery_link = "#{ENV.fetch('FRONTEND_URL', 'http://localhost:3000')}/api/v1/users/#{@user.id}/cart"

    mail(
      to:      @user.email,
      subject: "😮 Você esqueceu algo no carrinho! #{@cart_items.count} #{'item'.pluralize(@cart_items.count)}"
    )
  end
end
