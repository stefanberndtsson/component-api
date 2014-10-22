class AddColumnToAssetDataType < ActiveRecord::Migration
  def change
    add_column :asset_data_types, :dir, :text
  end
end
