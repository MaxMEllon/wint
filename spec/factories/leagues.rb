# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :league do
    name "MyString"
    start_at "2014-09-15"
    end_at "2014-09-15"
    limit_score 1.5
    is_analysis false
    src_dir "MyString"
    rule_file "MyString"
    is_active false
  end
end
