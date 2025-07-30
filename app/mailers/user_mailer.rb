class UserMailer < ApplicationMailer

  # app/views/user_mailer/account_activation.html[text].erb テンプレートを基に、
  # アカウント有効化用mailオブジェクトを作成する
  def account_activation(user)
    @user = user
    # mailオブジェクトを作成する
    mail to: user.email, subject: "Account activation"
    # => return: mail object(text/html)
  end

  # app/views/user_mailer/password_reset.html[text].erb テンプレートを基に、
  # パスワードリセット用mailオブジェクトを作成する
  def password_reset(user)
    @user = user
    mail to: user.email, subject: "Password reset"
  end
end
