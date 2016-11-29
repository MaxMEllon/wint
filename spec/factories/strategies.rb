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
      abc_size 11.765
      statement 256
      func_num 17
    end

    trait :type2 do
      score 44.82215
      abc_size 21.540
      statement 550
      func_num 18
    end

    trait :type3 do
      score 32.36735
      abc_size 15.346
      statement 142
      func_num 6
    end

    trait :type4 do
      score 52.02475
      abc_size 22.667
      statement 289
      func_num 8
    end

    trait :type5 do
      score 35.20245
      abc_size 23.309
      statement 485
      func_num 17
    end

    trait :type6 do
      score 400
      abc_size 1.0
      statement 1
      func_num 1
    end
  end
end

