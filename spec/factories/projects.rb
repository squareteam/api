FactoryGirl.define do
  factory :project do
    title 'Test project'
    association :owner, factory: :user

    trait :owned_by_user do
      association :owner, factory: :user, name: 'yo', email: 'yo@yo.fr'
    end

    trait :owned_by_organization do
      association :owner, factory: :organization
    end
  end
end
