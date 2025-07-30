class UserMailer < ApplicationMailer

  def account_activation(user)
    @user = user
    # mailオブジェクトを作成する
    mail to: user.email, subject: "Account activation"
    # => return: mail object(text/html)
  end

  def password_reset
    @greeting = "Hi"

    mail to: "to@example.org"
  end
end
