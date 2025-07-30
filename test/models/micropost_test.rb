require "test_helper"

class MicropostTest < ActiveSupport::TestCase
  def setup
    @user = users(:michael)
    # このコードは慣習的に正しくない
    #@micropost = Micropost.new(content: "Lorem ipsum", user_id: @user.id)
    # newとbuildはエイリアスメソッド
    @micropost = @user.microposts.build(content: "Lorem ipsum")
  end

  # バリデーション成功
  test "should be valid" do
    assert @micropost.valid?
  end

  # バリデーション失敗
  test "user id should be present" do
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end

  # 空文字チェック
  test "content should be present" do
    @micropost.content = "   "
    assert_not @micropost.valid?
  end

  # 文字数チェック
  test "content should be at most 140 characters" do
    @micropost.content = "a" * 141
    assert_not @micropost.valid?
  end

  # 並び順チェック
  test "order should be most recent first" do
    assert_equal microposts(:most_recent), Micropost.first
  end
end
