require "test_helper"

class UserTest < ActiveSupport::TestCase
  # setup:全てのテストの前に実行される
  def setup
    # password_digest:ではなく、password:、password_confirmation:（確認用）である点に注意
    @user = User.new(name: "Example User",email: "user@example.com",
                     password: "foobar", password_confirmation: "foobar")
  end

  test "should be valid" do
    assert @user.valid? # assert:引数がtrueならOK
  end

  test "name should be present" do
    @user.name = "     "
    assert_not @user.valid? # assert_not:引数がfalseならOK
  end

  test "email should be present" do
    @user.email = "     "
    assert_not @user.valid?
  end

  test "name should not be too long" do
    @user.name = "a" * 51 # 文字列のかけ算
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end

  # 正しいメールアドレス群が通るかのテスト
  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      # テスト失敗時に、どのアドレスで失敗したかを表示するようにしている
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  # 間違ったメールアドレス群がはじかれるかのテスト
  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "email addresses should be unique" do
    duplicate_user = @user.dup
    # duplicate_user.email = @user.email.upcase # アドレスを大文字にする
    @user.save
    assert_not duplicate_user.valid?
  end

  test "password should be present (nonblank)" do
    @user.password = @user.password_confirmation = " " * 6 # 「=」で繋いでまとめて代入する
    assert_not @user.valid?
  end

  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end
end
