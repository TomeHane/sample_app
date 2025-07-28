class UsersController < ApplicationController
  # GET /users/:id
  def show
    @user = User.find(params[:id])
    # このタイミングで処理を止める（Railsサーバのターミナルで確認できる）
    # debugger
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # POST /users (+ params)
  def create
    @user = User.new(user_params)
    if @user.save
      # ユーザー登録が成功したらそのままログインする
      reset_session
      log_in @user
      flash[:success] = "Welcome to the Sample App!"
      # GET "/users/#{@user.id}"
      redirect_to @user
      # redirect_to user_path(@user)
      # redirect_to user_path(@user.id)
      # redirect_to user_path(1)
      #             => /users/1
      # 以上のように、リダイレクト先をRailsが推察してくれる
    else
      # もう一回newテンプレートを表示する
      render 'new', status: :unprocessable_entity
    end
  end

  private

  # ストロングパラメータ
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
