class Relationship < ApplicationRecord
  # 規約通りの場合、Follower,Followedクラスを探しに行ってしまうため、
  # Userクラスに属することを明示している
  belongs_to :follower, class_name: "User"
  # => Relationship.follower_id と User(.id) が紐づく
  belongs_to :followed, class_name: "User"
  # => Relationship.followed_id と User(.id) が紐づく

  validates :follower_id, presence: true
  validates :followed_id, presence: true
end
