require 'rails_helper'

RSpec.describe Component, :type => :model do
  before :each do
    @amount = {}
    @amount[:one]      = Amount.create(name: "One",      can_have_spares: false, must_have_value: false)
    @amount[:few]      = Amount.create(name: "Few",      can_have_spares: false, must_have_value: false)
    @amount[:some]     = Amount.create(name: "Some",     can_have_spares: false, must_have_value: false)
    @amount[:several]  = Amount.create(name: "Several",  can_have_spares: false, must_have_value: false)
    @amount[:lots]     = Amount.create(name: "Lots",     can_have_spares: true,  must_have_value: false)
    @amount[:overflow] = Amount.create(name: "Overflow", can_have_spares: true,  must_have_value: false)
    @amount[:fixed]    = Amount.create(name: "Fixed",    can_have_spares: true,  must_have_value: true )
  end
  
  it "should save a complete component" do
    component = Component.new(name: "Test component",
                              summary: "Test Component summary",
                              description: "Test component description",
                              amount_id: @amount[:one].id,
                              spares: false)
    expect(component.save).to be_truthy
  end

  it { should validate_presence_of :name }
  it { should validate_presence_of :summary }
  it { should validate_presence_of :amount_id }
    
  it "should obey spares rule from amount setting" do
    component = Component.new(name: "Test component",
                              summary: "Test Component summary",
                              description: "Test component description",
                              amount_id: @amount[:one].id,
                              spares: true)
    expect(component.save).to be_falsey 
    component = Component.new(name: "Test component",
                              summary: "Test Component summary",
                              description: "Test component description",
                              amount_id: @amount[:lots].id,
                              spares: true)
    expect(component.save).to be_truthy
  end

  it "should obey value rule from amount setting" do
    component = Component.new(name: "Test component",
                              summary: "Test Component summary",
                              description: "Test component description",
                              amount_id: @amount[:fixed].id,
                              spares: false)
    expect(component.save).to be_falsey
    component = Component.new(name: "Test component",
                              summary: "Test Component summary",
                              description: "Test component description",
                              amount_id: @amount[:fixed].id,
                              amount_value: 123,
                              spares: false)
    expect(component.save).to be_truthy
  end
end
