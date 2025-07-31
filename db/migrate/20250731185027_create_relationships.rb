class CreateRelationships < ActiveRecord::Migration[7.0]
  def change
    create_table :relationships do |t|
      t.integer :follower_id
      t.integer :followed_id

      t.timestamps
    end
    # 高速化のためのインデックス
    add_index :relationships, :follower_id
    add_index :relationships, :followed_id
    # 2つのカラムがセットでユニークになること（一意性のためのインデックス）
    add_index :relationships, [:follower_id, :followed_id], unique: true
  end
end
