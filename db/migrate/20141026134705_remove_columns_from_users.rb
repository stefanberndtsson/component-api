class RemoveColumnsFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :token
    remove_column :users, :token_expire
  end
end
