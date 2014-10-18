FactoryGirl.define do
  factory :user_role do
    association :user
    association :team
    permissions 0
  end
end
