FactoryGirl.define do
  factory :user do
    name 'john'
    sequence :email do |n|
      "john#{n}@doe.com"
    end
    pbkdf 'xxxxx'
    salt 'xxxxx'
    provider 'squareteam'
    uid do
      SecureRandom.hex
    end
  end
end
