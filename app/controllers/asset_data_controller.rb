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
      send_file file_path, filename: asset.name, type: asset.content_type
    end
  end
end
