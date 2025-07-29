require "test_helper"

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @admin     = users(:michael)
    @non_admin = users(:archer)
  end

  # ページネーション、および削除リンクが正常に表示されるか
  test "index as admin including pagination and delete links" do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'  # ユーザ一覧ページが表示されるか
    assert_select 'div.pagination' # ページネーションのタグがあるか
    first_page_of_users = User.paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name  # 各ユーザのリンクが表示されるか
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete' # 各ユーザの削除リンクが表示されるか
      end
    end
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
      assert_response :see_other
      assert_redirected_to users_url
    end
  end

  # 管理者以外でログインした場合、削除リンクが存在しないか
  test "index as non-admin" do
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end
end
