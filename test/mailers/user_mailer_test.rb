require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "account_activation" do
    user = users(:michael)
    user.activation_token = User.new_token
    # ApplicationMailerを継承している場合、クラスメソッドのように呼び出されると、
    # 自動的にインスタンスを用意してそのメソッド（account_activation）を呼び出してくれる
    mail = UserMailer.account_activation(user)

    # 作成したmailオブジェクトについて、以下をチェック
    assert_equal "Account activation", mail.subject         # 件名
    assert_equal [user.email], mail.to                      # 宛先
    assert_equal ["user@realdomain.com"], mail.from         # 送信元
    assert_match user.name,               mail.body.encoded # 本文にユーザの名前が入っているか
    assert_match user.activation_token,   mail.body.encoded # 本文にトークンが入っているか
    assert_match CGI.escape(user.email),  mail.body.encoded # 本文にエスケープされたemailアドレスが入っているか
  end

  test "password_reset" do
    user = users(:michael)
    user.reset_token = User.new_token
    mail = UserMailer.password_reset(user)
    assert_equal "Password reset", mail.subject
    assert_equal [user.email], mail.to
    assert_equal ["user@realdomain.com"], mail.from
    assert_match user.reset_token,        mail.body.encoded
    assert_match CGI.escape(user.email),  mail.body.encoded
  end
end
