require 'rails_helper'

RSpec.describe ComponentsController, :type => :controller do
  fixtures :amounts
  fixtures :components
  describe "get list" do
    it "should return first page of paginated list of components when not specifying page" do
      Component.per_page = 4
      get :index
      expect(json).to have_key('components')
      expect(json['components'].count).to eq(4)
      expect(json).to have_key('meta')
      expect(json['meta']).to have_key('pagination')
      expect(json['meta']['pagination']['pages']).to eq((Component.count/4.0).ceil)
      expect(json['meta']['pagination']['page']).to eq(1)
      expect(json['meta']['pagination']['next']).to eq(2)
      expect(json['meta']['pagination']['previous']).to eq(nil)
    end

    it "should return second page of paginated list of components when giving page number 2" do
      Component.per_page = 4
      get :index, page: 2
      expect(json).to have_key('components')
      expect(json['components'].count).to eq(3)
      expect(json).to have_key('meta')
      expect(json['meta']).to have_key('pagination')
      expect(json['meta']['pagination']['pages']).to eq((Component.count/4.0).ceil)
      expect(json['meta']['pagination']['page']).to eq(2)
      expect(json['meta']['pagination']['next']).to eq(nil)
      expect(json['meta']['pagination']['previous']).to eq(1)
    end
    
    it "should return a list sorted by title by default" do
      Component.per_page = 4
      get :index
      expect(json['components'][0]['name']).to eq("Test component 1")
      expect(json['components'][1]['name']).to eq("Test component 2")
    end
  end
  
  describe "get component" do
    it "should return a single item" do
      get :show, id: 1
      expect(json).to have_key('component')
      expect(json['component']['name']).to eq("Test component 1")
    end

    it "should return 404 for non-existant component" do
      get :show, id: 9999999999999999
      expect(response.status).to eq(404)
      expect(json).to have_key('meta')
      expect(json['meta']).to have_key('errors')
    end
  end

  describe "create component" do
    it "should save a new component" do
      expect(Component.count).to eq(7)
      post :create, { component: {
          name: "New component",
          description: "New component description",
          amount_id: 1,
          spares: false
        }
      }
      expect(json).to have_key('component')
      expect(json['component']['name']).to eq('New component')
      expect(json['component']['id']).to eq(8)
      expect(Component.count).to eq(8)
    end

    it "should refuse to save invalid component with 422" do
      expect(Component.count).to eq(7)
      post :create, { component: {
          name: "New component",
          description: "New component description",
          amount_id: 1,
          spares: true
        }
      }
      expect(response.status).to eq(422)
      expect(json).to have_key('meta')
      expect(json['meta']).to have_key('errors')
      expect(Component.count).to eq(7)
    end
  end

  describe "update component" do
    it "should save an updated component" do
      expect(Component.find(1).name).to eq("Test component 1")
      put :update, { id: 1, component: {
          name: "New component name",
          description: "New component description",
          amount_id: 1,
          spares: false
        }
      }
      expect(json).to have_key('component')
      expect(json['component']['name']).to eq('New component name')
      expect(json['component']['id']).to eq(1)
      expect(Component.count).to eq(7)
      expect(Component.find(1).name).to eq("New component name")
    end

    it "should refuse to update invalid component with 422" do
      expect(Component.find(1).name).to eq("Test component 1")
      put :update, { id: 1, component: {
          name: "New component name",
          description: "New component description",
          amount_id: 1,
          spares: true
        }
      }
      expect(response.status).to eq(422)
      expect(json).to have_key('meta')
      expect(json['meta']).to have_key('errors')
      expect(Component.count).to eq(7)
      expect(Component.find(1).name).to eq("Test component 1")
    end

    it "should return 404 for non-existant component" do
      expect(Component.find(1).name).to eq("Test component 1")
      put :update, { id: 9999999999999999, component: {
          name: "New component name",
          description: "New component description",
          amount_id: 1,
          spares: true
        }
      }
      expect(response.status).to eq(404)
      expect(json).to have_key('meta')
      expect(json['meta']).to have_key('errors')
      expect(Component.count).to eq(7)
      expect(Component.find(1).name).to eq("Test component 1")
    end
  end
end
