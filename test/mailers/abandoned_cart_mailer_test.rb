require "test_helper"
require_relative "previews/abandoned_cart_mailer_preview"

class AbandonedCartMailerTest < ActionMailer::TestCase
  test "recovery_email renders abandoned cart details for the cart owner" do
    abandoned_cart = abandoned_carts(:one)

    mail = AbandonedCartMailer.recovery_email(abandoned_cart)

    assert_match "Voce esqueceu algo no carrinho", I18n.transliterate(mail.subject)
    assert_equal [ abandoned_cart.user.email ], mail.to
    assert_equal [ "noreply@eccomerce.com" ], mail.from
    assert_match abandoned_cart.user.name, mail.body.encoded
    assert_match abandoned_cart.cart.cart_items.first.product.name, mail.body.encoded
    assert_match "/api/v1/users/#{abandoned_cart.user.id}/cart", mail.body.encoded
  end

  test "preview builds a recovery email from an existing abandoned cart" do
    mail = AbandonedCartMailerPreview.new.recovery_email

    assert_equal [ AbandonedCart.order(:id).first.user.email ], mail.to
    assert_match "Voce esqueceu algo no carrinho", I18n.transliterate(mail.subject)
  end
end
