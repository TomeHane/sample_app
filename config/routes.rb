Rails.application.routes.draw do
  root 'static_pages#home' # => root(/)で表示するページをhomeに変更
  get 'static_pages/home' # => StaticPages#home
  get 'static_pages/help'
  get 'static_pages/about'
end
