require 'rails_helper'

RSpec.describe Tag, :type => :model do
  it "should save a complete tag" do
    tag = Tag.new(name: "New tag")
    expect(tag.save).to be_truthy
  end
  
  it "should require name" do
    tag = Tag.new()
    expect(tag.save).to be_falsey
  end
  
  it "should require unique name" do
    tag = Tag.new(name: "New tag")
    expect(tag.save).to be_truthy
    tag = Tag.new(name: "New tag")
    expect(tag.save).to be_falsey
  end
  
  it "should generate normalized name" do
    tag = Tag.new(name: "New tag")
    tag.save
    expect(tag.norm).to eq("new tag")
  end
  
  it "should require unique normalized name" do
    tag = Tag.new(name: "New tag")
    expect(tag.save).to be_truthy
    tag = Tag.new(name: "new tag")
    expect(tag.save).to be_falsey
  end
end
