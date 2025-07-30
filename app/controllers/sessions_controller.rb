class SessionsController < ApplicationController
  # GET /login
  def new
  end

  # POST /login
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      if user.activated?
        # セッションを削除する前に、リダイレクト先を変数に退避する
        forwarding_url = session[:forwarding_url]
        # ログインの直前に必ずセッション削除を行うこと（セッション固定攻撃対策）
        reset_session
        # 「Remember me on this computer」のチェックにより、処理を振り分ける
        params[:session][:remember_me] == '1' ? remember(user) : forget(user)
        log_in user
        # DBにダイジェストを、cookieにトークンと暗号化したユーザIDを記憶する
        # remember user
        # ログイン前のURL（なければユーザページ）にリダイレクトする
        redirect_to forwarding_url || user
      else
        message  = "Account not activated. "
        message += "Check your email for the activation link."
        flash[:warning] = message
        redirect_to root_url
      end
    else
      # エラーメッセージを作成する
      # alert-danger => 赤色のフラッシュ
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new', status: :unprocessable_entity
    end
  end

  # DELETE /logout
  def destroy
    log_out if logged_in?
    redirect_to root_url, status: :see_other # root_pathでもいいが、慣習的にroot_urlを指定する
  end
end
