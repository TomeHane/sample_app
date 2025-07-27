class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    # create_tableメソッドの呼び出し。tには、create_tableメソッドにより生成されたテーブルが渡される
    create_table :users do |t|
      t.string :name
      t.string :email

      t.timestamps
    end
  end
end
