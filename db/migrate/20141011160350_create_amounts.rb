class CreateAmounts < ActiveRecord::Migration
  def change
    create_table :amounts do |t|
      t.text :name
      t.text :description

      t.timestamps
    end
  end
end
