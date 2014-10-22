class AssetData < ActiveRecord::Base
  validates_presence_of :component_id
  validates_presence_of :asset_data_type_id
  validates_presence_of :name
  belongs_to :asset_data_type
  
  def upload_dir
    return path if path
    "#{component_id}/#{asset_data_type.dir}"
  end
end
