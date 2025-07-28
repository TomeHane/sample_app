require "test_helper"

class UsersSignupTest < ActionDispatch::IntegrationTest

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
    # usersのshowテンプレートが呼び出されているか
    assert_template 'users/show'
    # ログインしているか（is_logged_in?は、test/test_helper.rbに記述）
    assert is_logged_in?
  end
end
