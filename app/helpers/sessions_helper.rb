module SessionsHelper
  # 渡されたユーザーでログインする
  def log_in(user)
    session[:user_id] = user.id
  end

  # 現在ログイン中のユーザーを返す（いる場合）
  # 1.if文を書くことで、無駄にDBにクエリ（User.find_by）を送らないようにしている
  # 2.最初にクエリ結果をインスタンス変数にUserオブジェクトを格納しておき
  #   以降はインスタンス変数を返す（メモ化）
  # => DBへの問い合わせが極力少なくなる
  def current_user
    if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
    end
  end

  # ユーザーがログインしていればtrue、その他ならfalseを返す
  def logged_in?
    !current_user.nil?
  end

  # 現在のユーザーをログアウトする
  def log_out
    reset_session
    @current_user = nil   # 安全のため
  end
end
