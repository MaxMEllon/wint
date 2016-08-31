# == Schema Information
#
# Table name: strategies
#
#  id         :integer          not null, primary key
#  submit_id  :integer          not null
#  score      :float            default(0.0), not null
#  number     :integer          not null
#  analy_file :string(255)      default(""), not null
#  is_active  :boolean          default(TRUE), not null
#  created_at :datetime
#  updated_at :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :strategy do
    before :create do
      Strategy.skip_callback(:create, :after, :after_create)
    end
    after :create do
      Strategy.set_callback(:create, :after, :after_create)
    end

    number 1
    is_active true

    trait :type1 do
      score 49.43895
      abc_size 22.567
      statement 300
      func_num 16
    end

    trait :type2 do
      score 44.82215
      abc_size 32.192
      statement 590
      func_num 17
    end

    trait :type3 do
      score 32.36735
      abc_size 13.334
      statement 140
      func_num 5
    end

    trait :type4 do
      score 52.02475
      abc_size 35.21
      statement 245
      func_num 7
    end

    trait :type5 do
      score 35.20245
      abc_size 53.123
      statement 520
      func_num 16
    end
  end
end

