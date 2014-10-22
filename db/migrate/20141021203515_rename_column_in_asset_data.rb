class RenameColumnInAssetData < ActiveRecord::Migration
  def change
    rename_column :asset_data, :asset_type_id, :asset_data_type_id
  end
end
