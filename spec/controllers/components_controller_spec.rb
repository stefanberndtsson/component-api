require 'rails_helper'

RSpec.describe ComponentsController, :type => :controller do
  fixtures :amounts
  fixtures :components
  fixtures :tags
  before :each do
    user = User.new(username: "valid_username", password: "valid_password", name: "Valid User")
    user.save
    AccessToken.all.destroy_all
    @user = User.find_by_username("valid_username")
    @user.clear_expired_tokens
    @user.authenticate("valid_password")
    @token = @user.access_tokens.first.token
  end
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
    
    it "should return first page of paginated list of components when giving page beyond maximum page" do
      Component.per_page = 4
      get :index, page: 99999
      expect(json).to have_key('components')
      expect(json['components'].count).to eq(4)
      expect(json).to have_key('meta')
      expect(json['meta']).to have_key('pagination')
      expect(json['meta']['pagination']['pages']).to eq((Component.count/4.0).ceil)
      expect(json['meta']['pagination']['page']).to eq(1)
      expect(json['meta']['pagination']['next']).to eq(2)
      expect(json['meta']['pagination']['previous']).to eq(nil)
    end
    
    it "should return a list sorted by title by default" do
      Component.per_page = 4
      get :index
      expect(json['components'][0]['name']).to eq("Test component 1")
      expect(json['components'][1]['name']).to eq("Test component 2")
    end

    it "should extend token expire if token is provided" do
      pre_expire_time = @user.access_tokens.first.token_expire
      request.headers["Authorization"] = "Token #{@token}"
      get :index
      post_expire_time = AccessToken.find_by_token(@token).token_expire
      expect(pre_expire_time).to_not eq(post_expire_time)
    end

    it "should add session invalidation notification if token has expired" do
      request.headers["Authorization"] = "Token #{@token}"
      get :index
      expect(json['meta']).to_not have_key('notifications')
      @user.access_tokens.first.update_attribute(:token_expire, Time.now - 1.day)
      request.headers["Authorization"] = "Token #{@token}"
      get :index
      expect(json['meta']).to have_key('notifications')
      expect(json['meta']['notifications']['session_invalid']).to be_truthy
    end
  end
  
  describe "get component" do
    it "should return a single item" do
      get :show, id: 1
      expect(json).to have_key('component')
      expect(json['component']['name']).to eq("Test component 1")
    end

    it "should return amount as a string identifier" do
      get :show, id: 1
      expect(json).to have_key('component')
      expect(json['component']['amount']).to eq("One")
      get :show, id: 2
      expect(json).to have_key('component')
      expect(json['component']['amount']).to eq("Some")
      get :show, id: 5
      expect(json).to have_key('component')
      expect(json['component']['amount']).to eq("Fixed")
      expect(json['component']['amount_value']).to eq(42)
    end

    it "should return 404 for non-existant component" do
      get :show, id: 9999999999999999
      expect(response.status).to eq(404)
      expect(json).to have_key('meta')
      expect(json['meta']).to have_key('errors')
    end

    it "should include an array of tags if present" do
      component = Component.find(1)
      component.component_tags.create(tag_id: 2)
      component.component_tags.create(tag_id: 5)
      component.component_tags.create(tag_id: 6)
      get :show, id: 1
      expect(json).to have_key('component')
      expect(json['component']['name']).to eq("Test component 1")
      expect(json['component']['tags'].count).to eq(3)
      expect(json['component']['tags'].first).to eq("Tag 2")
    end

    it "should have tags sorted" do
      component = Component.find(1)
      component.component_tags.create(tag_id: 2)
      component.component_tags.create(tag_id: 5)
      component.component_tags.create(tag_id: 6)
      get :show, id: 1
      expect(json).to have_key('component')
      expect(json['component']['name']).to eq("Test component 1")
      expect(json['component']['tags'].count).to eq(3)
      expect(json['component']['tags'].first).to eq("Tag 2")

      component = Component.find(2)
      component.component_tags.create(tag_id: 6)
      component.component_tags.create(tag_id: 4)
      component.component_tags.create(tag_id: 3)
      get :show, id: 2
      expect(json).to have_key('component')
      expect(json['component']['name']).to eq("Test component 3")
      expect(json['component']['tags'].count).to eq(3)
      expect(json['component']['tags'].first).to eq("Tag 3")
    end

    it "should include files if available" do
      comp = Component.find(1)
      comp.asset_data.create(name: "Testfile Datasheet 1",
                             asset_data_type_id: AssetDataType.find_by_name("Datasheet").id)
      comp.asset_data.create(name: "Testfile Datasheet 2",
                             asset_data_type_id: AssetDataType.find_by_name("Datasheet").id)
      comp.asset_data.create(name: "Testfile Document 3",
                             asset_data_type_id: AssetDataType.find_by_name("Document").id)
      comp.asset_data.create(name: "Testfile Image 1",
                             asset_data_type_id: AssetDataType.find_by_name("Image").id)
      get :show, id: 1
      expect(json['component']).to have_key("files")
      expect(json['component']['files']).to_not be_empty
      expect(json['component']['files']).to have_key("datasheets")
      expect(json['component']['files']).to have_key("documents")
      expect(json['component']['files']).to have_key("images")
    end
  end

  describe "create component" do
    it "should require a valid token" do
      post :create, { component: {
          name: "New component",
          summary: "New component summary",
          description: "New component description",
          amount: "One",
          spares: false
        }
      }
      expect(response.status).to eq(401)
      expect(json['error']).to_not be_nil
    end
    it "should save a new component" do
      expect(Component.count).to eq(7)
      request.headers["Authorization"] = "Token #{@token}"
      post :create, { component: {
          name: "New component",
          summary: "New component summary",
          description: "New component description",
          amount: "One",
          spares: false
        }
      }
      expect(json).to have_key('component')
      expect(json['component']['name']).to eq('New component')
      expect(json['component']['id']).to eq(8)
      expect(Component.count).to eq(8)
      new_component = Component.find(8)
      expect(new_component.amount.name).to eq("One")
    end

    it "should refuse to save invalid component with 422" do
      expect(Component.count).to eq(7)
      request.headers["Authorization"] = "Token #{@token}"
      post :create, { component: {
          name: "New component",
          summary: "New component summary",
          description: "New component description",
          amount: "One",
          spares: true
        }
      }
      expect(response.status).to eq(422)
      expect(json).to have_key('errors')
      expect(Component.count).to eq(7)
    end
    
    it "should accept a list of tags to save with component" do
      expect(Tag.count).to eq(6)
      request.headers["Authorization"] = "Token #{@token}"
      post :create, { component: {
          name: "New component",
          summary: "New component summary",
          description: "New component description",
          amount: "One",
          spares: false,
          tags: ["tag 1", "Tag 2", "tag 4", "Tag 7"]
        }
      }
      component = Component.find(json['component']['id'])
      expect(component.tags.first.name).to eq('Tag 1')
      expect(component.tags.count).to eq(4)
      expect(Tag.count).to eq(7)
    end
  end

  describe "update component" do
    it "should require a valid token" do
      put :update, { id: 1, component: {
          name: "New component name",
          description: "New component description",
          amount: "One",
          spares: false
        }
      }
      expect(response.status).to eq(401)
      expect(json['error']).to_not be_nil
    end

    it "should save an updated component" do
      expect(Component.find(1).name).to eq("Test component 1")
      request.headers["Authorization"] = "Token #{@token}"
      put :update, { id: 1, component: {
          name: "New component name",
          description: "New component description",
          amount: "One",
          spares: false
        }
      }
      expect(json).to have_key('component')
      expect(json['component']['name']).to eq('New component name')
      expect(json['component']['id']).to eq(1)
      expect(Component.count).to eq(7)
      expect(Component.find(1).name).to eq("New component name")
    end

    it "should require amount as string for an updated component" do
      expect(Component.find(1).name).to eq("Test component 1")
      request.headers["Authorization"] = "Token #{@token}"
      put :update, { id: 1, component: {
          name: "New component name",
          description: "New component description",
          amount: "Some",
          spares: false
        }
      }
      expect(json).to have_key('component')
      expect(json['component']['name']).to eq('New component name')
      expect(json['component']['id']).to eq(1)
      expect(Component.count).to eq(7)
      expect(Component.find(1).name).to eq("New component name")
      expect(Component.find(1).amount_id).to eq(3)
    end

    it "should refuse to update invalid component with 422" do
      expect(Component.find(1).name).to eq("Test component 1")
      request.headers["Authorization"] = "Token #{@token}"
      put :update, { id: 1, component: {
          name: "New component name",
          description: "New component description",
          amount: "One",
          spares: true
        }
      }
      expect(response.status).to eq(422)
      expect(json).to have_key('errors')
      expect(Component.count).to eq(7)
      expect(Component.find(1).name).to eq("Test component 1")
    end

    it "should return 404 for non-existant component" do
      expect(Component.find(1).name).to eq("Test component 1")
      request.headers["Authorization"] = "Token #{@token}"
      put :update, { id: 9999999999999999, component: {
          name: "New component name",
          description: "New component description",
          amount: "One",
          spares: true
        }
      }
      expect(response.status).to eq(404)
      expect(json).to have_key('meta')
      expect(json['meta']).to have_key('errors')
      expect(Component.count).to eq(7)
      expect(Component.find(1).name).to eq("Test component 1")
    end

    it "should accept a list of tags to save with component" do
      request.headers["Authorization"] = "Token #{@token}"
      put :update, { id: 1, component: {
          name: "New component",
          description: "New component description",
          amount: "One",
          spares: false,
          tags: ["tag 1", "Tag 2", "Tag 4"]
        }
      }
      component = Component.find(json['component']['id'])
      expect(component.tags.first.name).to eq('Tag 1')
      expect(component.tags.count).to eq(3)
    end

    it "should accept a list of tags to save with component, replacing previous list" do
      request.headers["Authorization"] = "Token #{@token}"
      put :update, { id: 1, component: {
          name: "New component",
          description: "New component description",
          amount: "One",
          spares: false,
          tags: ["tag 1", "Tag 2", "Tag 4"]
        }
      }
      component = Component.find(json['component']['id'])
      expect(component.tags.first.name).to eq('Tag 1')
      expect(component.tags.count).to eq(3)
      @json = nil
      request.headers["Authorization"] = "Token #{@token}"
      put :update, { id: 1, component: {
          name: "New component",
          description: "New component description",
          amount: "One",
          spares: false,
          tags: ["tag 2", "Tag 3", "tag 5", "Tag 6"]
        }
      }
      component = Component.find(json['component']['id'])
      expect(component.tags.first.name).to eq('Tag 2')
      expect(component.tags.count).to eq(4)
    end
    
    it "should accept a list of tags to save with component, replacing previous list, unless update fails" do
      expect(Tag.count).to eq(6)
      request.headers["Authorization"] = "Token #{@token}"
      put :update, { id: 1, component: {
          name: "New component",
          description: "New component description",
          amount: "One",
          spares: false,
          tags: ["tag 1", "Tag 2", "tag 4", "Tag 7"]
        }
      }
      component = Component.find(json['component']['id'])
      expect(component.tags.first.name).to eq('Tag 1')
      expect(component.tags.count).to eq(4)
      expect(Tag.count).to eq(7)
      @json = nil
      request.headers["Authorization"] = "Token #{@token}"
      put :update, { id: 1, component: {
          name: "New component",
          description: "New component description",
          amount: "One",
          spares: true,
          tags: ["tag 2", "tag 3", "tag 5", "Tag 8", "Tag 9"]
        }
      }
      component = Component.find(1)
      expect(component.tags.first.name).to eq('Tag 1')
      expect(component.tags.count).to eq(4)
      expect(Tag.count).to eq(7)
    end
  end
end
