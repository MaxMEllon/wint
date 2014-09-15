# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    snum "MyString"
    name "MyString"
    password_digest "MyString"
    depart 1
    entrance 1
    category 1
    is_active false
  end
end
