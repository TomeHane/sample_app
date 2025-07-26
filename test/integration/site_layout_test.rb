require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest
  test 'layout links' do
    get root_path                                  # rootにアクセス
    assert_template 'static_pages/home'            # homeテンプレートが表示されているか？
    assert_select 'a[href=?]', root_path, count: 2 # root_path(homeページ)へのリンクが2つあるか？
    assert_select 'a[href=?]', help_path           # helpページへのリンクがあるか？
    assert_select 'a[href=?]', about_path          # aboutページへのリンクがあるか？
    assert_select 'a[href=?]', contact_path        # contactページへのリンクがあるか？
  end
end
