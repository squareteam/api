FactoryGirl.define do
  factory :mission do
    title 'Test mission'
    association :creator, factory: :user
    association :project
  end
end
