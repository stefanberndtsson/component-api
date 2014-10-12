require 'rails_helper'

RSpec.describe ComponentTag, :type => :model do
  fixtures :components
  fixtures :tags

  before :each do
    @tag1 = Tag.find(1)
    @tag2 = Tag.find(2)
    @tag3 = Tag.find(3)
  end

  it "should add valid tags" do
    component = Component.find(1)
    expect(component.component_tags.count).to eq(0)
    component.component_tags.create(tag_id: @tag1)
    expect(component.component_tags.count).to eq(1)
  end

  it "should add multiple valid tags" do
    component = Component.find(1)
    expect(component.component_tags.count).to eq(0)
    component.component_tags.create(tag_id: @tag1.id)
    component.component_tags.create(tag_id: @tag2.id)
    expect(component.component_tags.count).to eq(2)
  end

  it "should not add the same tag twice, but fail silently" do
    component = Component.find(1)
    expect(component.component_tags.count).to eq(0)
    component.component_tags.create(tag_id: @tag1.id)
    component.component_tags.create(tag_id: @tag1.id)
    expect(component.component_tags.count).to eq(1)
  end
end
