require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

  test "should get new" do
    get signup_path
    assert_response :success
  end

  # ログインしてない状態で編集画面に行こうとした場合、エラーメッセージとともにログイン画面に戻されるか
  test "should redirect edit when not logged in" do
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  # ログインしてない状態で編集しようとした場合、エラーメッセージとともにログイン画面に戻されるか
  test "should redirect update when not logged in" do
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email } }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  # 別のユーザの編集画面に行こうとした場合、エラーメッセージとともにログイン画面に戻されるか
  test "should redirect edit when logged in as wrong user" do
    log_in_as(@other_user)
    get edit_user_path(@user)
    assert flash.empty?
    assert_redirected_to root_url
  end

  # 別のユーザで編集しようとした場合、エラーメッセージとともにログイン画面に戻されるか
  test "should redirect update when logged in as wrong user" do
    log_in_as(@other_user)
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email } }
    assert flash.empty?
    assert_redirected_to root_url
  end

  # ユーザ一覧画面アクセス失敗
  test "should redirect index when not logged in" do
    # ユーザ一覧画面にアクセスする（users_path ≠ user_path）
    get users_path
    assert_redirected_to login_url
  end

  # ユーザ削除失敗（ログインしないケース）
  test "should redirect destroy when not logged in" do
    # ログインせずにDELETEリクエストを送っても、ユーザ数が変わらないか
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_response :see_other
    assert_redirected_to login_url
  end

  # ユーザ削除失敗（管理者でないケース）
  test "should redirect destroy when logged in as a non-admin" do
    log_in_as(@other_user)
    # 管理者権限を持たずにDELETEリクエストを送っても、ユーザ数が変わらないか
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_response :see_other
    assert_redirected_to root_url
  end

  test "should redirect following when not logged in" do
    get following_user_path(@user)
    assert_redirected_to login_url
  end

  test "should redirect followers when not logged in" do
    get followers_user_path(@user)
    assert_redirected_to login_url
  end
end
