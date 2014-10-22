class AssetDataType < ActiveRecord::Base
  has_many :asset_data
  validates_presence_of :name
  validates_presence_of :dir
end
