FactoryGirl.define do
  factory :mission do
    title 'Test mission'
    association :creator, factory: :user
    association :project

    factory :mission_with_tasks do
      transient do
        tasks_count 5
      end

      after(:create) do |mission, evaluator|
        create_list(:task, evaluator.tasks_count, mission: mission)
      end
    end
  end
end
