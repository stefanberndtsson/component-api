class AssetDataController < ApplicationController
  before_filter :validate_token, only: [:create]
  
  def create
    infile = params[:file]
    name = infile.original_filename
    data_type = AssetDataType.find_by_name(params[:data_type])
    component = Component.find(params[:component_id])
    if component
      upload_root = Rails.configuration.upload_root
      asset_data = component.asset_data.build(name: name, asset_data_type_id: data_type.id)
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
end
