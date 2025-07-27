class UsersController < ApplicationController
  # GET /users/:id
  def show
    @user = User.find(params[:id])
    # このタイミングで処理を止める（Railsサーバのターミナルで確認できる）
    # debugger
  end

  def new; end
end
