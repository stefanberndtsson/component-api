require 'rails_helper'

RSpec.describe SearchesController, :type => :controller do
  fixtures :components
  before :each do
    test = Component.create(name: "Component more easily searchable",
                            description: "Better form of description",
                            amount_id: 1,
                            spares: false)
    test.add_tag("Long")
    test.add_tag("Long tag name")
  end

  describe "search data" do
    it "should return empty list when query missing or empty" do
      get :index
      expect(json['results']).to be_empty
      expect(json['results'].count).to eq(0)
    end
    
    it "should return filtered list when query is provided" do
      get :index, query: "test"
      expect(json['results']).to_not be_empty
      expect(json['results'].count).to eq(7)
      get :index, query: "easily"
      expect(json['results']).to_not be_empty
      expect(json['results'].count).to eq(1)
    end

    it "should return sorted list" do
      get :index, query: "test"
      expect(json['results']).to_not be_empty
      expect(json['results'].count).to eq(7)
      expect(json['results'][0]['name']).to eq('Test component 1')
      expect(json['results'][1]['name']).to eq('Test component 2')
      expect(json['results'][2]['name']).to eq('Test component 3')
    end

    it "should treat query as case insensitive" do
      get :index, query: "Test"
      expect(json['results']).to_not be_empty
      expect(json['results'].count).to eq(7)
    end

    it "should query description" do
      get :index, query: "better"
      expect(json['results']).to_not be_empty
      expect(json['results'].count).to eq(1)
    end

    it "should query tags as full match only" do
      get :index, query: "long"
      expect(json['results']).to_not be_empty
      expect(json['results'].count).to eq(1)
      get :index, query: "tag"
      expect(json['results']).to be_empty
      expect(json['results'].count).to eq(0)
    end

    it "should return metadata about query" do
      get :index, query: "Test"
      expect(json['results']).to_not be_empty
      expect(json['results'].count).to eq(7)
      expect(json['meta']['query']['query']).to eq("Test")
      expect(json['meta']['query']['total']).to eq(7)
    end

    it "should return metadata about pagination" do
      Component.per_page = 4
      get :index, query: "Test"
      expect(json['results']).to_not be_empty
      expect(json['results'].count).to eq(4)
      expect(json['meta']['query']['query']).to eq("Test")
      expect(json['meta']['query']['total']).to eq(7)
      expect(json['meta']['pagination']['pages']).to eq(2)
      expect(json['meta']['pagination']['page']).to eq(1)
      expect(json['meta']['pagination']['next']).to eq(2)
      expect(json['meta']['pagination']['previous']).to eq(nil)
    end

    it "should return paginated second page when given page number" do
      Component.per_page = 4
      get :index, query: "Test", page: 2
      expect(json['results']).to_not be_empty
      expect(json['results'].count).to eq(3)
      expect(json['meta']['query']['query']).to eq("Test")
      expect(json['meta']['query']['total']).to eq(7)
      expect(json['meta']['pagination']['pages']).to eq(2)
      expect(json['meta']['pagination']['page']).to eq(2)
      expect(json['meta']['pagination']['next']).to eq(nil)
      expect(json['meta']['pagination']['previous']).to eq(1)
    end

    it "should return first page when given out of bounds page number" do
      Component.per_page = 4
      get :index, query: "Test", page: 20000000000
      expect(json['results']).to_not be_empty
      expect(json['results'].count).to eq(4)
      expect(json['meta']['query']['query']).to eq("Test")
      expect(json['meta']['query']['total']).to eq(7)
      expect(json['meta']['pagination']['pages']).to eq(2)
      expect(json['meta']['pagination']['page']).to eq(1)
      expect(json['meta']['pagination']['next']).to eq(2)
      expect(json['meta']['pagination']['previous']).to eq(nil)
    end
  end
end
