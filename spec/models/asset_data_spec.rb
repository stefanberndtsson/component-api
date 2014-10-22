require 'rails_helper'

RSpec.describe AssetData, :type => :model do
  fixtures :components
  
  before :each do
    @upload_root = Rails.configuration.upload_root
    @data_type = AssetDataType.create(name: "Test Data Type", dir: "testdir")
    @component = Component.find(1)
  end
  
  it "should save a complete file post" do
    ad = AssetData.new(asset_data_type_id: @data_type.id,
                       name: "Test file", path: "/tmp",
                       component_id: @component.id)
    expect(ad.save).to be_truthy
  end
  
  it "should require component" do
    ad = AssetData.new(asset_data_type_id: @data_type.id,
                       name: "Test file", path: "/tmp")
    expect(ad.save).to be_falsey
  end

  it "should require asset_data_type" do
    ad = AssetData.new(name: "Test file", path: "/tmp",
                       component_id: @component.id)
    expect(ad.save).to be_falsey
  end
  
  it "should require name" do
    ad = AssetData.new(asset_data_type_id: @data_type.id,
                       path: "/tmp",
                       component_id: @component.id)
    expect(ad.save).to be_falsey
  end
  
  it "should provide upload sub directory" do
    ad = AssetData.new(asset_data_type_id: @data_type.id,
                       name: "Test file", path: "/tmp",
                       component_id: @component.id)
    expect(ad.upload_dir).to eq("/tmp")
    ad = AssetData.new(asset_data_type_id: @data_type.id,
                       name: "Test file",
                       component_id: @component.id)
    expect(ad.upload_dir).to eq("#{ad.component_id}/#{ad.asset_data_type.dir}")
  end
end
