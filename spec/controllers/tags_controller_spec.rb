require 'rails_helper'

RSpec.describe TagsController, :type => :controller do
#  fixtures :tags
  describe "get list" do
    before :each do
      create(:tag, id: 1, name: "Tag 1", norm: "tag 1")
      create(:tag, id: 2, name: "Tag 2", norm: "tag 2")
      create(:tag, id: 3, name: "Tag 3", norm: "tag 3")
      create(:tag, id: 4, name: "Tag 4", norm: "tag 4")
      create(:tag, id: 5, name: "Tag 5", norm: "tag 5")
      create(:tag, id: 6, name: "Tag 6", norm: "tag 6")
    end
    it "should return list of all tags" do
      get :index
      expect(json).to have_key('tags')
      expect(json['tags'].count).to eq(6)
      expect(json['tags'][0]['name']).to eq('Tag 1')
    end
  end
end
