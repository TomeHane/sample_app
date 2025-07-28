require "test_helper"

class UsersLoginTest < ActionDispatch::IntegrationTest

  # ログインテスト用のダミーユーザーを用意する
  def setup
    # usersはfixtureのファイル名users.ymlを表し、:michaelはユーザーを参照するためのキーを表す。
    @user = users(:michael)
  end

  # ログイン失敗時
  test "login with valid email/invalid password" do
    get login_path
    assert_template 'sessions/new'
    post login_path, params: { session: { email: @user.email, password: "invalid" } }
    assert_not is_logged_in? # ログインしてないか
    assert_response :unprocessable_entity
    assert_template 'sessions/new'
    assert_not flash.empty?  # flashが空でないか
    get root_path
    assert flash.empty?      # flashが空か
  end

  # ログイン成功　=> ログアウト
  test "login with valid information followed by logout" do
    # ログイン
    post login_path, params: { session: { email: @user.email, password: 'password' } }
    assert is_logged_in?                            # ログインしているか
    assert_redirected_to @user                      # リダイレクト先がユーザーのプロフィールページか
    follow_redirect!
    assert_template 'users/show'                    # プロフィールページが表示されているか
    assert_select "a[href=?]", login_path, count: 0 # ヘッダーにログインのリンクがないか
    assert_select "a[href=?]", logout_path          # ヘッダーにログアウトのリンクがあるか
    assert_select "a[href=?]", user_path(@user)     # プロフィールページへのリンクがあるか

    # ログアウト
    delete logout_path
    assert_not is_logged_in?
    assert_response :see_other
    assert_redirected_to root_url
    # 2番目のウィンドウでログアウトをクリックするユーザーをシミュレートする
    delete logout_path
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path,      count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end

  # ダイジェストが存在しない場合のauthenticated?のテスト
  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?('')
  end

  # チェックあり（cookieに情報が保持される）
  test "login with remembering" do
    log_in_as(@user, remember_me: '1')
    assert_not cookies[:remember_token].blank?
  end

  # チェックなし（cookieに情報が保持されない）
  test "login without remembering" do
    # Cookieを保存してログイン
    log_in_as(@user, remember_me: '1')
    delete logout_path
    # Cookieが削除されていることを検証してからログイン
    log_in_as(@user, remember_me: '0')
    assert cookies[:remember_token].blank?
  end
end
