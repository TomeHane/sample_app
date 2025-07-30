class AccountActivationsController < ApplicationController

  # GET /account_activations/:id/edit
  # アカウント有効化メールのリンクがクリックされたときの処理
  def edit
    user = User.find_by(email: params[:email])
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      # パラメータが書き換えらえてない、かつアカウント有効化済みでない、かつトークンとダイジェストが一致する場合
      # user.update_attribute(:activated,    true)
      # user.update_attribute(:activated_at, Time.zone.now)
      # ↓ メソッド化によるリファクタリング
      user.activate
      log_in user
      flash[:success] = "Account activated!"
      redirect_to user
    else
      flash[:danger] = "Invalid activation link"
      redirect_to root_url
    end
  end
end
