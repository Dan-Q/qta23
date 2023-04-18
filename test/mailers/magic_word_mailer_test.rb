require "test_helper"

class MagicWordMailerTest < ActionMailer::TestCase
  test "remind" do
    mail = MagicWordMailer.remind
    assert_equal "Remind", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
