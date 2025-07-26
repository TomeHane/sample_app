Rails.application.routes.draw do
  root 'static_pages#home' # => root(/)で表示するページをhomeに変更
  get 'static_pages/home' # => StaticPages#home URLとコントローラー名#アクション名が密結合している書き方（あまり使わない）
  get 'static_pages/help'
  get 'static_pages/about'
  get  "static_pages/contact"
end
