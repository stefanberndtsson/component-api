require 'rails_helper'
require 'fileutils'

class TestUploadObject < Struct.new(:original_filename, :content_type, :data)
  def read
    @data_io ||= StringIO.new(@data)
    @data_io.read
  end
end

RSpec.describe AssetDataController, :type => :controller do
  fixtures :components
  fixtures :asset_data_types

  before :each do
    @upload_root = Rails.configuration.upload_root
    FileUtils.mkdir_p(@upload_root)
    
    @component = Component.find(1)
    @testpdf = fixture_file_upload('files/Testfile.pdf', 'application/pdf')
    @testdoc = fixture_file_upload('files/Testfile.odt', 'application/vnd.oasis.opendocument.text')
    @testimg = fixture_file_upload('files/Testfile.jpg', 'image/jpeg')
    user = User.new(username: "valid_username", password: "valid_password", name: "Valid User")
    user.save
    @user = User.find_by_username("valid_username")
    @user.authenticate("valid_password")
  end
  
  after :each do
    FileUtils.rm_rf(@upload_root)
  end

  describe "upload asset data" do
    it "should require valid token" do
      post :create, component_id: @component.id, data_type: "Datasheet", file: @testpdf
      expect(response.status).to eq(401)
      expect(json['error']).to_not be_nil
    end
    
    it "should accept a full upload package" do
      post :create, component_id: @component.id, data_type: "Datasheet", file: @testpdf, token: @user.token
      expect(response.status).to eq(200)
      component = Component.find(1)
      assets = component.asset_data
      expect(assets.count).to eq(1)
      expect(File.exist?("#{@upload_root}/#{assets.first.upload_dir}/Testfile.pdf")).to be_truthy
      expect(assets.first.content_type).to eq("application/pdf")
    end
  end
  
  describe "get asset" do
    it "should return the file when given id" do
      post :create, component_id: @component.id, data_type: "Datasheet", file: @testpdf, token: @user.token
      component = Component.find(@component.id)
      get :show, id: component.asset_data.first.id
      testpdf = fixture_file_upload('files/Testfile.pdf', 'application/pdf')
      expect(Digest::SHA1.hexdigest(response.body)).to eq(Digest::SHA1.hexdigest(testpdf.read))
      expect(response.content_type).to eq(testpdf.content_type)
    end
  end
end
