require 'rails_helper'

RSpec.describe AccessToken, :type => :model do
  before :each do
    @user = User.create(username: "valid_user", password: "valid_password", name: "Valid User")
  end
  
  it "should save a proper token" do
    at = AccessToken.new(user_id: @user.id, token: SecureRandom.hex, token_expire: Time.now+1.day)
    expect(at.save).to be_truthy
  end
end
