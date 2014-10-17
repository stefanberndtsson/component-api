require 'rails_helper'

RSpec.describe User, :type => :model do
  before :all do
    BCrypt::Engine.cost = 1  # Reduce cost to speed up test...
  end
  it "should save a complete user" do
    user = User.new(username: "testuser", password: "foobar", name: "Test User")
    expect(user.save).to be_truthy
  end

  it "should require username" do
    user = User.new(password: "foobar", name: "Test User")
    expect(user.save).to be_falsey
  end

  it "should have unique username" do
    user = User.new(username: "testuser", password: "foobar", name: "Test User")
    expect(user.save).to be_truthy
    user = User.new(username: "testuser", password: "foobar", name: "Test User")
    expect(user.save).to be_falsey
  end

  it "should require password" do
    user = User.new(username: "testuser", name: "Test User")
    expect(user.save).to be_falsey
  end

  it "should require name" do
    user = User.new(username: "testuser", password: "foobar")
    expect(user.save).to be_falsey
  end

  it "should store encrypted password" do
    user = User.new(username: "testuser", password: "foobar", name: "Test User")
    expect(user.save).to be_truthy
    expect(user.password).to_not be("foobar")
    expect(BCrypt::Password.valid_hash?(user.password)).to be_truthy
  end

  it "should not reencrypt password" do
    user = User.new(username: "testuser", password: "foobar", name: "Test User")
    expect(user.save).to be_truthy
    user.update_attribute(:name, "New Name")
    pass = BCrypt::Password.new(user.password)
    expect(pass).to eq("foobar")
  end
  
  it "should authenticate credentials" do
    user = User.new(username: "testuser", password: "foobar", name: "Test User")
    user.save
    expect(user.authenticate("foobar")).to be_truthy
  end

  it "should fail authentication on bad credentials" do
    user = User.new(username: "testuser", password: "foobar", name: "Test User")
    user.save
    expect(user.authenticate("wrong")).to be_falsey
  end

  it "should generate token with expire time on authentication" do
    user = User.new(username: "testuser", password: "foobar", name: "Test User")
    user.save
    expect(user.token).to be_nil
    expect(user.authenticate("foobar")).to be_truthy
    expect(user.token).to_not be_nil
    expect(user.token_expire).to be_within(1.day).of(Time.now)
  end

  it "should not generate token on failed authentication" do
    user = User.new(username: "testuser", password: "foobar", name: "Test User")
    user.save
    expect(user.token).to be_nil
    expect(user.authenticate("wrong")).to be_falsey
    expect(user.token).to be_nil
  end

  it "should validate token" do
    user = User.new(username: "testuser", password: "foobar", name: "Test User")
    user.save
    expect(user.authenticate("foobar")).to be_truthy
    token = user.token
    expect(user.validate_token(token)).to be_truthy
  end

  it "should clear token when validating if expired" do
    user = User.new(username: "testuser", password: "foobar", name: "Test User")
    user.save
    expect(user.authenticate("foobar")).to be_truthy
    token = user.token
    expect(user.validate_token(token)).to be_truthy
    expect(user.token_expire).to be_within(1.day).of(Time.now)
    user.token_expire = Time.now - 1.day
    expect(user.token_expire).to_not be_within(1.day).of(Time.now)
    expect(user.validate_token(token)).to be_falsey
    expect(user.token).to be_nil
  end

end
