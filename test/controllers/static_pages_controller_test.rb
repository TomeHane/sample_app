require "test_helper"

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    get static_pages_home_url
    assert_response :success # レスポンスが正常に返ってくるか？
  end

  test "should get help" do
    get static_pages_help_url
    assert_response :success
  end
end
