class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.text :username
      t.text :password
      t.text :name
      t.text :token
      t.timestamp :token_expire

      t.timestamps
    end
  end
end
