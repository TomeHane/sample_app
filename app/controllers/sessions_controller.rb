class SessionsController < ApplicationController
  # GET /login
  def new
  end

  # POST /login
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      # ユーザーログイン後にユーザー情報のページにリダイレクトする
    else
      # alert-danger => 赤色のフラッシュ
      flash.now[:danger] = 'Invalid email/password combination'
      # エラーメッセージを作成する
      render 'new', status: :unprocessable_entity
    end
  end
end
