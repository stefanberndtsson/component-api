class CreateAssetDataTypes < ActiveRecord::Migration
  def change
    create_table :asset_data_types do |t|
      t.text :name

      t.timestamps
    end
  end
end
