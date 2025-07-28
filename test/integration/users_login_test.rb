require "test_helper"

class UsersLoginTest < ActionDispatch::IntegrationTest
    # バグを見つけたら、直す前に再現テストを書く
    test "login with invalid information" do
    get login_path
    assert_template 'sessions/new'
    post login_path, params: { session: { email: "", password: "" } }
    assert_response :unprocessable_entity
    assert_template 'sessions/new'
    assert_not flash.empty? # flashが空でないか
    get root_path
    assert flash.empty?     # flashが空か
  end
end
