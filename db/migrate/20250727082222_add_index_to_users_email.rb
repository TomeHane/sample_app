class AddIndexToUsersEmail < ActiveRecord::Migration[7.0]
  def change
    # DB側でもメールアドレスに一意性を持つよう指示
    add_index :users, :email, unique: true
  end
end
