require 'rails_helper'

RSpec.describe SessionController, :type => :controller do
  before :each do
    @user = User.create(username: "valid_user", password: "valid_password", name: "Valid User")
  end
  describe "create session" do
    it "should return access_token on valid credentials" do
      post :create, username: "valid_user", password: "valid_password"
      user = User.find_by_username("valid_user")
      expect(json['access_token']).to be_truthy
      expect(json['token_type']).to eq("bearer")
      expect(json['access_token']).to eq(user.access_tokens.first.token)
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
    
    it "should allow the same user to login multiple times, getting different tokens" do
      post :create, username: "valid_user", password: "valid_password"
      token1 = json['access_token']
      post :create, username: "valid_user", password: "valid_password"
      token2 = json['access_token']
      get :show, id: token1
      expect(response.status).to eq(200)
      get :show, id: token2
      expect(response.status).to eq(200)
    end
  end
  
  describe "validate session" do
    it "should return ok on valid session and extend expire time" do
      post :create, username: "valid_user", password: "valid_password"
      token = json['access_token']
      token_object = AccessToken.find_by_token(token)
      first_expire = token_object.token_expire
      get :show, id: token
      expect(json['access_token']).to eq(token)
      token_object = AccessToken.find_by_token(token)
      second_expire = token_object.token_expire
      expect(first_expire).to_not eq(second_expire)
    end

    it "should return 401 on invalid session and clear token" do
      post :create, username: "valid_user", password: "valid_password"
      token = json['access_token']
      token_object = AccessToken.find_by_token(token)
      token_object.update_attribute(:token_expire, Time.now - 1.day)
      get :show, id: token
      expect(response.status).to eq(401)
      expect(json).to have_key("error")
    end

    it "should return user data on valid session" do
      post :create, username: "valid_user", password: "valid_password"
      user = User.find_by_username("valid_user")
      get :show, id: json['access_token']
      expect(json['user']['name']).to eq(user.name)
    end
  end
end
