Rails.application.routes.draw do
  get 'static_pages/home' # => StaticPages#home
  get 'static_pages/help'
  get 'static_pages/about'
  root "hello#index"
end
