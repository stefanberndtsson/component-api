FactoryGirl.define do
  sequence :tag_name do |i| 
    "Tag #{i}"
  end

  sequence :tag_norm do |i| 
    "tag #{i}"
  end

  factory :tag do
    name { generate :tag_name }
    norm { generate :tag_norm }
  end
end
