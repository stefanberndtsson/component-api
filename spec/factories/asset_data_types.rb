FactoryGirl.define do
  sequence :asset_data_type_name do |i| 
    "Asset_data_type #{i}"
  end

  sequence :asset_data_type_dir do |i| 
    "asset_data_type #{i}"
  end

  factory :asset_data_type do
    name { generate :asset_data_type_name }
    dir { generate :asset_data_type_dir }
  end
end
