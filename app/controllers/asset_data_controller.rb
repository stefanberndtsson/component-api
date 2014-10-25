class AssetDataController < ApplicationController
  before_filter :validate_token, only: [:create]
  
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
    upload_root = Rails.configuration.upload_root
    dir_path = "#{upload_root}/#{asset.upload_dir}"
    thumbnail_path = "#{upload_root}/#{asset.thumbnail_dir}"
    thumbnail_name = Pathname.new(asset.name).sub_ext(".png")
    thumbnail_file_path = "#{thumbnail_path}/#{size}_#{thumbnail_name}"
    file_path = "#{dir_path}/#{asset.name}"
    if File.exist?(thumbnail_file_path)
      send_file thumbnail_file_path, type: 'image/png', disposition: 'inline'
    elsif File.exist?(file_path)
      image = MiniMagick::Image.open(file_path)
      image.resize "#{size}x#{size}"
      image.format "png"
      FileUtils.mkdir_p(thumbnail_path)
      image.write thumbnail_file_path
      send_data image.to_blob, type: 'image/png', disposition: 'inline'
    end
  end
end
