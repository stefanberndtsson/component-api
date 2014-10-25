class AssetData < ActiveRecord::Base
  validates_presence_of :component_id
  validates_presence_of :asset_data_type_id
  validates_presence_of :name
  belongs_to :asset_data_type
  
  def upload_dir
    return path if path
    "#{component_id}/#{asset_data_type.dir}"
  end
  
  def thumbnail_dir
    "thumbnail/#{component_id}/#{asset_data_type.dir}"
  end
  
  def generate_thumbnail(size)
    upload_root = Rails.configuration.upload_root
    dir_path = "#{upload_root}/#{upload_dir}"
    thumbnail_path = "#{upload_root}/#{thumbnail_dir}"
    thumbnail_name = Pathname.new(name).sub_ext(".png")
    thumbnail_file_path = "#{thumbnail_path}/#{size}_#{thumbnail_name}"
    file_path = "#{dir_path}/#{name}"
    
    return thumbnail_file_path if File.exist?(thumbnail_file_path)
    return nil if !File.exist?(file_path)

    FileUtils.mkdir_p(thumbnail_path)
    cmd = ["convert", "-resize", "#{size}x#{size}", file_path+"[0]", thumbnail_file_path]
    IO.popen(cmd) do |stdout|
      stdout.read
    end
    
    return thumbnail_file_path
  end
end
