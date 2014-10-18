FactoryGirl.define do
  factory :team do
    association :organization
    sequence :name do |n|
      "swcc#{n}"
    end
  end
end
