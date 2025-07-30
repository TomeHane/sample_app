class User < ApplicationRecord
  # 仮想的な（DBに保存されない）カラム
  # 実際にDBに保存されるのはトークンをハッシュ化したもの（ダイジェスト）
  attr_accessor :remember_token, :activation_token
  
  # DBにUPSERTされる直前に動く
  # before_save { self.email = email.downcase }
  before_save   :downcase_email
  # DBにINSERTされる直前に動く
  before_create :create_activation_digest
  
  validates :name, presence: true,
                   length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true,
                    length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: true
  # allow_nil: trueでパスワードが空であることを許容しているが、
  # has_secure_passwordで、ユーザ生成時にパスワードがnilでないことをチェックしているので問題ない
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

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
  def authenticated?(attribute, token)
    # インスタンス.send("メソッド名")で、指定のメソッドを呼び出すことができる
    # ex. @user.send("remember_digest") => @user.remember_digest
    digest = send("#{attribute}_digest")
    # DBのダイジェストがnilだったら、処理を中断してfalseを返す
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # 引数なしのforgetメソッド（インスタンスメソッド）
  # ユーザーのログイン情報を破棄する
  def forget
    # remember_digestカラムをnilに更新する（接頭のself.が省略されている）
    update_attribute(:remember_digest, nil)
  end

  # アカウントを有効にする
  def activate
    update_attribute(:activated,    true)
    update_attribute(:activated_at, Time.zone.now)
  end

  # 有効化用のメールを送信する
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  private

  # メールアドレスをすべて小文字にする
  def downcase_email
    self.email = email.downcase
  end

  # 有効化トークンとダイジェストを作成および代入する
  def create_activation_digest
    self.activation_token  = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end
