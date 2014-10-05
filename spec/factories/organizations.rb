FactoryGirl.define do
  factory :organization do
    sequence :name do |n|
      "swcc#{n}"
    end
  end
end
