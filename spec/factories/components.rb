FactoryGirl.define do
  sequence :component_name do |i| 
    "Test component #{i}"
  end

  sequence :component_summary do |i| 
    "Test component #{i} summary"
  end

  sequence :component_description do |i| 
    "Test component #{i} description"
  end

  factory :component do
    name { generate :component_name }
    summary { generate :component_summary }
    description { generate :component_description }
    association :amount, factory: [:amount]
    spares false
    amount_value nil
  end
end
