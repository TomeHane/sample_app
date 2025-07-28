class User < ApplicationRecord
  # 仮想的な（DBに保存されない）カラム
  # 実際にDBに保存されるのはトークンをハッシュ化したもの（remember_digest）
  attr_accessor :remember_token

  before_save { self.email = email.downcase }
  validates :name, presence: true,
                   length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true,
                    length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: true
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }

  # 渡された文字列のハッシュ値を返す
  def User.digest(string)
    # テスト環境なら低コスト、本番環境なら高コストでハッシュ化（三項演算子を使っている）
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # ランダムなトークンを返す
  def User.new_token
    # URLでも使えるランダムな文字列を生成する
    SecureRandom.urlsafe_base64
  end

  # 引数なしのrememberメソッド（インスタンスメソッド）
  # 永続的セッションのためにユーザーをデータベースに記憶する
  def remember
    # トークンを生成し、インスタンス変数（仮想カラム）に格納する
    self.remember_token = User.new_token
    # トークンからダイジェストを生成し、update_attributeを使って、remember_digestカラムのみ更新する
    # トークンを生成するのもダイジェストを作るのもコンピューターであるため、バリデーションチェックは不要
    # 接頭のself.が省略されている
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # 渡されたトークンがダイジェストと一致したらtrueを返す
  def authenticated?(remember_token)
    # DBのダイジェストがnilだったら、処理を中断してfalseを返す
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # 引数なしのforgetメソッド（インスタンスメソッド）
  # ユーザーのログイン情報を破棄する
  def forget
    # remember_digestカラムをnilに更新する（接頭のself.が省略されている）
    update_attribute(:remember_digest, nil)
  end
end
