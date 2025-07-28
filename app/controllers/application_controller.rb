class ApplicationController < ActionController::Base
  include SessionsHelper # 全コントローラーからセッション関連のヘルパーを呼び出せるようにしておく
end
