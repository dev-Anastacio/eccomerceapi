require "test_helper"

class AbandonedCartMailerTest < ActionMailer::TestCase
  test "recovery_email" do
    mail = AbandonedCartMailer.recovery_email
    assert_equal "Recovery email", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end
end
