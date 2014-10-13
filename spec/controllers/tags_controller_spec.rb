require 'rails_helper'

RSpec.describe TagsController, :type => :controller do
  fixtures :tags
  describe "get list" do
    it "should return list of all tags" do
      get :index
      expect(json).to have_key('tags')
      expect(json['tags'].count).to eq(6)
      expect(json['tags'][0]['name']).to eq('Tag 1')
    end
  end
end
