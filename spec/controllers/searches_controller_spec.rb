require 'rails_helper'

RSpec.describe SearchesController, :type => :controller do
  fixtures :components
  before :each do
    test = Component.create(name: "Component more easily searchable",
                            summary: "New component summary",
                            description: "Better form of description",
                            amount_id: 1,
                            spares: false)
    test.add_tag("Long")
    test.add_tag("Long tag name")
    Component.per_page = 10000
  end

  describe "search data" do
    it "should return all items when query missing or empty" do
      get :index
      expect(json['results']).to_not be_empty
      expect(json['results'].count).to eq(8)
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
      expect(json['meta']['pagination']['per_page']).to eq(4)
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
  
  describe "special query" do
    before :each do
      adt = AssetDataType.find_by_name("Datasheet")
      AssetData.create(asset_data_type_id: adt.id,
                       component_id: 1,
                       name: "Datasheet_1.pdf", content_type: 'application/pdf')
      AssetData.create(asset_data_type_id: adt.id,
                       component_id: 2,
                       name: "Datasheet_2.pdf", content_type: 'application/pdf')
      adt = AssetDataType.find_by_name("Document")
      AssetData.create(asset_data_type_id: adt.id,
                       component_id: 2,
                       name: "Document_1.pdf", content_type: 'application/pdf')
      adt = AssetDataType.find_by_name("Image")
      AssetData.create(asset_data_type_id: adt.id,
                       component_id: 2,
                       name: "Image_1.jpg", content_type: 'application/pdf')
      AssetData.create(asset_data_type_id: adt.id,
                       component_id: 3,
                       name: "Image_2.jpg", content_type: 'application/pdf')
    end
  
    describe "with asset" do
      it "should return only components with datasheets when searching for special:with-datasheet" do
        get :index, query: "special:with-datasheet"
        expect(json['results']).to_not be_empty
        expect(json['results'].count).to eq(2)
      end
      
      it "should return only components with documents when searching for special:with-document" do
        get :index, query: "special:with-document"
        expect(json['results']).to_not be_empty
        expect(json['results'].count).to eq(1)
      end

      it "should return only components with images when searching for special:with-image" do
        get :index, query: "special:with-image"
        expect(json['results']).to_not be_empty
        expect(json['results'].count).to eq(2)
      end

      it "should return only components with files when searching for special:with-file" do
        get :index, query: "special:with-file"
        expect(json['results']).to_not be_empty
        expect(json['results'].count).to eq(3)
      end
    end
    
    describe "without asset" do
      it "should return only components with datasheets when searching for special:without-datasheet" do
        get :index, query: "special:without-datasheet"
        expect(json['results']).to_not be_empty
        expect(json['results'].count).to eq(6)
      end
      
      it "should return only components with documents when searching for special:without-document" do
        get :index, query: "special:without-document"
        expect(json['results']).to_not be_empty
        expect(json['results'].count).to eq(7)
      end

      it "should return only components with images when searching for special:without-image" do
        get :index, query: "special:without-image"
        expect(json['results']).to_not be_empty
        expect(json['results'].count).to eq(6)
      end

      it "should return only components with files when searching for special:without-file" do
        get :index, query: "special:without-file"
        expect(json['results']).to_not be_empty
        expect(json['results'].count).to eq(5)
      end
    end
  end
  
  describe "tags query" do
    it "should return only tags matching" do
      get :index, query: "tags:long"
      expect(json['results'].count).to eq(1)
    end

    it "should treat everything following the tags query indicator as part of a single tag name" do
      get :index, query: "tags:long tag name"
      expect(json['results'].count).to eq(1)
    end
  end
end
