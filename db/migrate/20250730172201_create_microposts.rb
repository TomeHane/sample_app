class CreateMicroposts < ActiveRecord::Migration[7.0]
  def change
    create_table :microposts do |t|
      t.text :content
      # null: false ・・・ nullを禁止する
      # foreign_key: true ・・・ 外部キー（別のテーブルを参照するためのカラム）
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    # インデックス（≒目次・索引）の作成を指示し、高速化をはかる
    # micropostsを参照する際は、user_idとcreated_atもセットで参照することをDBに伝えておく
    add_index :microposts, %i[user_id created_at]
  end
end
