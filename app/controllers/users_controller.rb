class UsersController < ApplicationController
  # edit, updateメソッドが呼び出される前に、logged_in_user, correct_userメソッドを呼び出す
  # 必ずlogged_in_userフィルター => correct_user の順番にすること（∵correct_userはログインしていることが前提）
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy

  # GET /users
  def index
    @users = User.paginate(page: params[:page]) # ページネーション
  end

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

  # GET /users/:id/edit
  # PATCHリクエストを送るためのフォームを生成する
  def edit
    @user = User.find(params[:id])
    # => app/views/users/edit.html.erb
  end

  # PATCH /users/:id
  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  # DELETE /users/:id
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url, status: :see_other
  end

  private

  # ストロングパラメータ
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  # beforeフィルタ

  # ログイン済みユーザーかどうか確認
  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "Please log in."
      redirect_to login_url, status: :see_other
    end
  end

  # 正しいユーザーかどうか確認
  # ログインの有無はlogged_in_userでチェックしているので、ログイン周りは気にしなくてOK
  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url, status: :see_other) unless current_user? @user
  end

  # 管理者かどうか確認
  def admin_user
    redirect_to(root_url, status: :see_other) unless current_user.admin?
  end
end
