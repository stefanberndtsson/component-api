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
    @testimg2 = fixture_file_upload('files/Other.jpg', 'image/jpeg')
    user = User.new(username: "valid_username", password: "valid_password", name: "Valid User")
    user.save
    @user = User.find_by_username("valid_username")
    @user.authenticate("valid_password")
    @token = @user.access_tokens.first.token
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
      post :create, component_id: @component.id, data_type: "Datasheet", file: @testpdf, token: @token
      expect(response.status).to eq(200)
      component = Component.find(1)
      assets = component.asset_data
      expect(assets.count).to eq(1)
      expect(File.exist?("#{@upload_root}/#{assets.first.upload_dir}/Testfile.pdf")).to be_truthy
      expect(assets.first.content_type).to eq("application/pdf")
    end
  end

  describe "remove asset" do
    it "should require valid token" do
      post :create, component_id: @component.id, data_type: "Datasheet", file: @testpdf, token: @token
      component = Component.find(1)
      assets = component.asset_data
      delete :destroy, id: assets.first.id
      expect(response.status).to eq(401)
      expect(json['error']).to_not be_nil
    end

    it "should remove asset from database" do
      post :create, component_id: @component.id, data_type: "Datasheet", file: @testpdf, token: @token
      expect(response.status).to eq(200)
      component = Component.find(1)
      assets = component.asset_data
      expect(assets.count).to eq(1)
      delete :destroy, id: assets.first.id, token: @token
      component = Component.find(1)
      assets = component.asset_data
      expect(assets.count).to eq(0)
    end

    it "should remove asset file from filesystem" do
      post :create, component_id: @component.id, data_type: "Datasheet", file: @testpdf, token: @token
      expect(response.status).to eq(200)
      component = Component.find(1)
      assets = component.asset_data
      upload_dir = assets.first.upload_dir
      delete :destroy, id: assets.first.id, token: @token
      expect(File.exist?("#{@upload_root}/#{upload_dir}/Testfile.pdf")).to be_falsey
    end

    it "should remove thumbnail files from filesystem" do
      post :create, component_id: @component.id, data_type: "Datasheet", file: @testpdf, token: @token
      expect(response.status).to eq(200)
      post :create, component_id: @component.id, data_type: "Datasheet", file: @testimg2, token: @token
      expect(response.status).to eq(200)
      component = Component.find(1)
      assets = component.asset_data
      thumbnail_dir = assets.first.thumbnail_dir
      get :thumbnail, id: assets.first.id, size: 320
      get :thumbnail, id: assets.first.id, size: 160
      get :thumbnail, id: assets.last.id, size: 320
      get :thumbnail, id: assets.last.id, size: 160
      delete :destroy, id: assets.first.id, token: @token
      expect(File.exist?("#{@upload_root}/#{thumbnail_dir}/320_Testfile.pdf.png")).to be_falsey
      expect(File.exist?("#{@upload_root}/#{thumbnail_dir}/160_Testfile.pdf.png")).to be_falsey
      expect(File.exist?("#{@upload_root}/#{thumbnail_dir}/320_Other.jpg.png")).to be_truthy
      expect(File.exist?("#{@upload_root}/#{thumbnail_dir}/160_Other.jpg.png")).to be_truthy
    end
  end
  
  describe "get asset" do
    it "should return the file when given id" do
      post :create, component_id: @component.id, data_type: "Datasheet", file: @testpdf, token: @token
      component = Component.find(@component.id)
      get :show, id: component.asset_data.first.id
      testpdf = fixture_file_upload('files/Testfile.pdf', 'application/pdf')
      expect(Digest::SHA1.hexdigest(response.body)).to eq(Digest::SHA1.hexdigest(testpdf.read))
      expect(response.content_type).to eq(testpdf.content_type)
    end
  end

  describe "get thumbnail" do
    it "should return thumbnail when given id" do
      post :create, component_id: @component.id, data_type: "Datasheet", file: @testimg, token: @token
      component = Component.find(@component.id)
      get :thumbnail, id: component.asset_data.first.id, size: 320
      image = MiniMagick::Image.read(StringIO.new(response.body))
      expect(image.width).to be <= 320
    end
    
    it "should cache thumbnail after generating" do
      post :create, component_id: @component.id, data_type: "Datasheet", file: @testimg, token: @token
      component = Component.find(@component.id)
      size = 320
      name = @testimg.original_filename+".png"
      get :thumbnail, id: component.asset_data.first.id, size: size
      expect(File.exist?("#{@upload_root}/#{component.asset_data.first.thumbnail_dir}/#{size}_#{name}")).to be_truthy
      get :thumbnail, id: component.asset_data.first.id, size: size
    end
  end
end
