class AddColumnToAssetData < ActiveRecord::Migration
  def change
    add_column :asset_data, :content_type, :text
  end
end
