require 'rails_helper'

RSpec.describe Amount, :type => :model do
  it "should save a complete amount object" do
    amount = Amount.new(name: "One", description: "Only one left",
                        can_have_spares: false, must_have_value: false)
    expect(amount.save).to be_truthy
  end
  it "should require name" do
    amount = Amount.new(description: "Only one left")
    expect(amount.save).to be_falsey
  end
  it "should specify if spares are possible" do
    amount = Amount.new(name: "One")
    expect(amount.save).to be_falsey
  end
  it "should specify if value is required" do
    amount = Amount.new(name: "One")
    expect(amount.save).to be_falsey
  end
end
