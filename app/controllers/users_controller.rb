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
      # 保存の成功をここで扱う。
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
