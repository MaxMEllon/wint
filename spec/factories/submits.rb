# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :submit do
    player_id 1
    src_file "MyString"
    comment "MyString"
    number 1
    status 1
    is_active false
  end
end
