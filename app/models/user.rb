class User < ApplicationRecord
  # has_many：ユーザーがマイクロポストを複数所有する関連付け
  # dependent: :destroy：マイクロポストは、その所有者（ユーザー）と一緒に破棄されることを保証する
  has_many :microposts, dependent: :destroy
  # => Default: class_name: "Micropost"
  # => Default: foreign_key: "user_id"

  # class_name:  参照するモデル[クラス]
  # foreign_key: 外部キー（Userテーブルのidカラムと紐づくカラム）
  has_many :active_relationships, class_name:  "Relationship",
                                  foreign_key: "follower_id",
                                  dependent:   :destroy
  # => Default: class_name:  "ActiveRelationship" NG
  # => Default: foreign_key: "user_id"            NG

  has_many :passive_relationships, class_name:  "Relationship",
                                   foreign_key: "followed_id",
                                   dependent:   :destroy

  # 1.Userオブジェクトはfollowingメソッドを呼び出せるようになる
  # 2.followingメソッドは、@user.active_relationships.map(&:followed) と同義！
  has_many :following, through: :active_relationships,
                       source: :followed

  has_many :followers, through: :passive_relationships,
                       source: :follower

  # 仮想的な（DBに保存されない）カラム
  # 実際にDBに保存されるのはトークンをハッシュ化したもの（ダイジェスト）
  attr_accessor :remember_token, :activation_token, :reset_token

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
    UserMailer.account_activation(self).deliver_now # selfにはUserオブジェクトが入る
  end

  # パスワード再設定の属性を設定する
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest,  User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  # パスワード再設定のメールを送信する
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # パスワード再設定の期限が切れている場合はtrueを返す
  def password_reset_expired?
    # reset_sent_atカラムが2時間前以内ならtrue
    self.reset_sent_at < 2.hours.ago
  end

   # ユーザーのステータスフィードを返す
  def feed
    # ユーザのフォローしている人のID（self.following_ids）と、
    # ユーザ自身のID（self.id）と一致するマイクロポストをDBから取得する
    # ?があることで、SQLクエリに代入する前にidがエスケープされ、SQLインジェクションを防げる
    #Micropost.where("user_id IN (?) OR user_id = ?", following_ids, id)

    # さらにSQLを一行にまとめることも可能（サブセレクトを使う）
    # whereメソッド内の変数に、キーと値のペアを使うことも可能
    following_ids = "SELECT followed_id FROM relationships
                     WHERE  follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids})
                     OR user_id = :user_id", user_id: id)
  end

  # ユーザーをフォローする
  def follow(other_user)
    following << other_user unless self == other_user # DBにも反映される
  end

  # ユーザーをフォロー解除する
  def unfollow(other_user)
    following.delete(other_user)
  end

  # 現在のユーザーが他のユーザーをフォローしていればtrueを返す
  def following?(other_user)
    following.include?(other_user) # DBから取得する
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
