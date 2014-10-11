class CreateComponents < ActiveRecord::Migration
  def change
    create_table :components do |t|
      t.text :name
      t.text :description
      t.integer :amount_id
      t.integer :amount_value
      t.boolean :spares

      t.timestamps
    end
  end
end
