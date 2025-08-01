class RelationshipsController < ApplicationController
  # onlyを書かない場合、このクラスの全アクションの前でlogged_in_userが走る
  before_action :logged_in_user

  # POST /relationships
  def create
    @user = User.find(params[:followed_id])
    current_user.follow(@user)
    # リクエストの種類により、レスポンス方法を切り替える
    respond_to do |format|
      format.html { redirect_to @user } # HTMLリクエストの場合
      format.js                         # Ajaxリクエストの場合
      # => Default: app/views/relationships/create.js.erb
    end
  end

  # POST /relationships/:id
  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow(@user)
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
      # => Default: app/views/relationships/destroy.js.erb
    end
  end
end
