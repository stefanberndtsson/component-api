require 'rails_helper'

RSpec.describe AmountsController, :type => :controller do
#  fixtures :amounts

  describe "get list" do
    before :each do
      create(:amount, name: "One")
    end
    it "should return all amount settings" do
      get :index
      expect(json).to have_key('amounts')
      expect(json['amounts'][0]['name']).to eq('One')
    end
  end
end
