require 'rails_helper'

RSpec.describe SessionController, :type => :controller do
  before :each do
    User.create(username: "valid_user", password: "valid_password", name: "Valid User")
  end
  describe "create session" do
    it "should return access_token on valid credentials" do
      post :create, username: "valid_user", password: "valid_password"
      user = User.find_by_username("valid_user")
      expect(json['access_token']).to be_truthy
      expect(json['token_type']).to eq("bearer")
      expect(json['access_token']).to eq(user.token)
    end
    
    it "should return 401 with error on invalid credentials" do
      post :create, username: "invalid_user", password: "invalid_password"
      expect(response.status).to eq(401)
      expect(json['error']).to be_truthy
    end
    
    it "should return user data on valid credentials" do
      post :create, username: "valid_user", password: "valid_password"
      user = User.find_by_username("valid_user")
      expect(json['user']['name']).to eq(user.name)
    end

    it "should not return user password hash on valid credentials" do
      post :create, username: "valid_user", password: "valid_password"
      expect(json['user']).to_not have_key('password')
    end
  end
end
