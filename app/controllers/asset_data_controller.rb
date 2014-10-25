class AssetDataController < ApplicationController
  before_filter :validate_token, only: [:create, :destroy]
  
  def create
    infile = params[:file]
    name = infile.original_filename
    content_type = infile.content_type
    data_type = AssetDataType.find_by_name(params[:data_type])
    component = Component.find(params[:component_id])
    if component
      upload_root = Rails.configuration.upload_root
      asset_data = component.asset_data.build(name: name,
                                              asset_data_type_id: data_type.id,
                                              content_type: content_type)
      upload_dir = "#{upload_root}/#{asset_data.upload_dir}"
      FileUtils.mkdir_p(upload_dir)
      File.open("#{upload_dir}/#{name}", "wb") do |file|
        file.write(infile.read)
      end
      if component.save
        render json: {}
        return
      end
    end
    render json: {}
  end
  
  def show
    asset = AssetData.find(params[:id])
    upload_root = Rails.configuration.upload_root
    dir_path = "#{upload_root}/#{asset.upload_dir}"
    file_path = "#{dir_path}/#{asset.name}"
    if File.exist?(file_path)
      send_file file_path, filename: asset.name, type: asset.content_type, disposition: 'inline'
    end
  end
  
  def thumbnail
    asset = AssetData.find(params[:id])
    size = params[:size].to_i
    thumbnail_file_path = asset.generate_thumbnail(size)
    if thumbnail_file_path
      send_file thumbnail_file_path, type: 'image/png', disposition: 'inline'
    end
  end

  def destroy
    asset_data = AssetData.find(params[:id])
    asset_data.destroy
    upload_root = Rails.configuration.upload_root
    dir_path = "#{upload_root}/#{asset_data.upload_dir}"
    file_path = "#{dir_path}/#{asset_data.name}"
    if File.exist?(file_path)
      FileUtils.rm(file_path)
    end
    thumbnail_dir = "#{upload_root}/#{asset_data.thumbnail_dir}"
    if Dir.exist?(thumbnail_dir)
      thumbnail_match_name = Pathname.new(asset_data.name).sub_ext(".png").to_s
      Pathname.new(thumbnail_dir).children.each do |child|
        thumbname = child.basename.to_s[/^\d+_(.*)$/,1]
        FileUtils.rm(child) if thumbname == thumbnail_match_name
      end
    end
    render json: {}
  end
end
