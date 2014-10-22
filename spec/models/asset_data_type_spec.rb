require 'rails_helper'

RSpec.describe AssetDataType, :type => :model do
  it "should save a proper asset data type" do
    adt = AssetDataType.new(name: "Test Datatype", dir: "testdir")
    expect(adt.save).to be_truthy
  end
  it "should require name" do
    adt = AssetDataType.new(dir: "testdir")
    expect(adt.save).to be_falsey
  end
  it "should require dir" do
    adt = AssetDataType.new(name: "Test Datatype")
    expect(adt.save).to be_falsey
  end
end
