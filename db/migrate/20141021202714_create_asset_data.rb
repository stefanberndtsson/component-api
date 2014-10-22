class CreateAssetData < ActiveRecord::Migration
  def change
    create_table :asset_data do |t|
      t.integer :asset_type_id
      t.text :name
      t.text :path
      t.integer :component_id

      t.timestamps
    end
  end
end
