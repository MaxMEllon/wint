# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :strategy do
    submit_id 1
    score 1.5
    number 1
    analy_file "MyString"
    is_active false
  end
end
