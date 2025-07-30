class Micropost < ApplicationRecord
  # マイクロポストがユーザーに所属する（belongs_to）関連付け
  belongs_to :user
  # DBから複数のデータを取得する際、デフォルトで新しい順にする
  # データを取得するタイミングで都度メソッドを実行する必要があるため、lambdaを用いる
  default_scope -> { order(created_at: :desc) }
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
end
