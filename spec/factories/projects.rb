FactoryGirl.define do
  factory :project do
    title 'Test project'
    association :owner, factory: :user, name: 'yo', email: 'yo@yo.fr'
  end
end
