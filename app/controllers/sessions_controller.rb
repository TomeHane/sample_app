class SessionsController < ApplicationController
  # GET /login
  def new
  end

  # POST /login
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      # ユーザーログイン後にユーザー情報のページにリダイレクトする
      reset_session      # ログインの直前に必ずこれを書くこと（セッション固定攻撃対策）
      log_in user
      redirect_to user
    else
      # エラーメッセージを作成する
      # alert-danger => 赤色のフラッシュ
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new', status: :unprocessable_entity
    end
  end

  # DELETE /logout
  def destroy
    log_out
    redirect_to root_url, status: :see_other # root_pathでもいいが、慣習的にroot_urlを指定する
  end
end
