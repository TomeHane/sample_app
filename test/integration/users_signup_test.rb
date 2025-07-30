require "test_helper"

class UsersSignupTest < ActionDispatch::IntegrationTest

  def setup
    # テスト前に送信メールをクリアする
    ActionMailer::Base.deliveries.clear
  end

  # ユーザー登録失敗時のテスト
  test "invalid signup information" do
    get signup_path
    # POSTリクエストを送る前後で、Userの数が変わらないか
    assert_no_difference 'User.count' do
      post users_path, params: { user: { name:  "",
                                         email: "user@invalid",
                                         password:              "foo",
                                         password_confirmation: "bar" } }
    end
    assert_response :unprocessable_entity
    # usersのnewテンプレートが呼び出されているか
    assert_template 'users/new'
  end

  # アカウント有効化処理の追加に伴い、以下のテストを廃止
=begin
  # ユーザー登録成功時のテスト
  test "valid signup information" do
    # POSTリクエストを送る前後で、Userの数が１つ増えるか
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name:  "Example User",
                                         email: "user@example.com",
                                         password:              "password",
                                         password_confirmation: "password" } }
    end
    # コントローラーの記述に従ってリダイレクトする
    # リダイレクトする直前の状態をテストしたい場合があるため、明示的に記述する必要がある
    follow_redirect!
    
    # サインアップ後のログイン廃止により、以下のテストも廃止
    ## usersのshowテンプレートが呼び出されているか
    #assert_template 'users/show'
    ## ログインしているか（is_logged_in?は、test/test_helper.rbに記述）
    #assert is_logged_in?
  end
=end

  # ユーザー登録成功時のテスト
  test "valid signup information with account activation" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name:  "Example User",
                                         email: "user@example.com",
                                         password:              "password",
                                         password_confirmation: "password" } }
    end
    # メールを1件送っているか
    assert_equal 1, ActionMailer::Base.deliveries.size
    # 対応するアクション（users_controller.rbのcreateアクション）のインスタンス変数（@user）にアクセスする
    user = assigns(:user)
    assert_not user.activated?
    # 有効化していない状態でログインしてみる
    log_in_as(user)
    assert_not is_logged_in?
    # 有効化トークンが不正な場合
    get edit_account_activation_path("invalid token", email: user.email)
    assert_not is_logged_in?
    # トークンは正しいがメールアドレスが無効な場合
    get edit_account_activation_path(user.activation_token, email: 'wrong')
    assert_not is_logged_in?
    # 有効化トークンが正しい場合
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
  end
end
