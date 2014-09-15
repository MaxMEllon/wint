# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :player do
    user_id 1
    league_id 1
    name "MyString"
    role 1
    submit_id 1
    is_active false
  end
end
