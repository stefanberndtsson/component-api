FactoryGirl.define do
  sequence :amount_name do |i| 
    "Amount #{i}"
  end

  factory :amount do
    name { generate :amount_name }
    description nil
    unsparable
    inexplicit_count

    trait :sparable do
      can_have_spares true
    end

    trait :unsparable do
      can_have_spares false
    end

    trait :explicit_count do
      must_have_value true
    end

    trait :inexplicit_count do
      must_have_value false
    end
  end
end
