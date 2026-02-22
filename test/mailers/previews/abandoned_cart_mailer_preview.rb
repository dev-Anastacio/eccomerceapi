# Preview all emails at http://localhost:3000/rails/mailers/abandoned_cart_mailer
class AbandonedCartMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/abandoned_cart_mailer/recovery_email
  def recovery_email
    AbandonedCartMailer.recovery_email
  end
end
