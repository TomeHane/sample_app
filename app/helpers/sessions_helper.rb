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
  # def current_user
  #   if session[:user_id]
  #     @current_user ||= User.find_by(id: session[:user_id])
  #   end
  # end

  # 記憶トークンcookieに対応するユーザーを返す
  def current_user
    # セッションにあるユーザIDを取得する
    if (user_id = session[:user_id])
      # インスタンス変数にUserオブジェクトを格納する（初回のみ）
      @current_user ||= User.find_by(id: user_id)

    # セッションにユーザIDがなければ、cookieにある暗号化したユーザIDを取得する（encryptedで復号化）
    elsif (user_id = cookies.encrypted[:user_id])
      # 復号したユーザIDでDBからUserオブジェクトを取得する
      user = User.find_by(id: user_id)
      # 該当のユーザが見つかり、かつダイジェストが一致した場合
      if user && user.authenticated?(cookies[:remember_token])
        # ログイン処理を行う
        log_in user
        # インスタンス変数にUserオブジェクトを格納する
        @current_user = user
      end
    end
  end

  # 渡されたユーザーがカレントユーザーであればtrueを返す
  def current_user?(user)
    user && user == current_user
  end

  # ユーザーがログインしていればtrue、その他ならfalseを返す
  def logged_in?
    !current_user.nil?
  end

  # 現在のユーザーをログアウトする
  def log_out
    forget(current_user)  # DBのダイジェスト、cookieのユーザID・トークンを削除する
    reset_session
    @current_user = nil   # 安全のため
  end

  # 引数ありのrememberメソッド（クラスメソッド）
  # 永続的セッションのためにユーザーをデータベースに記憶する
  def remember(user)
    # user.rbのrememberメソッドを呼び出し、トークンを生成したうえ、DBにダイジェストを記憶する
    user.remember
    # ユーザIDを暗号化（encrypted）し、cookieに永続的に（permanent）保存する
    # cookieに保存する際は期限を指定する必要がある
    cookies.permanent.encrypted[:user_id] = user.id
    # トークンをcookieに永続的に保存する
    cookies.permanent[:remember_token] = user.remember_token
  end

  # 引数ありのforgetメソッド（クラスメソッド）
  # 永続的セッションを破棄する
  def forget(user)
    # user.rbのforgetメソッドを呼び出し、DBに記憶したダイジェストを削除する（nilにする）
    user.forget
    # cookieに保存したユーザIDとトークンを削除する
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # アクセスしようとしたURLを保存する
  def store_location
    # GETリクエストの場合、リクエストのURL（ユーザがアクセスしようとしていた場所）をセッションに保存する
    session[:forwarding_url] = request.original_url if request.get?
  end
end
