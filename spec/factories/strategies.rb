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
      line 350
      size 8779
      gzip_size 1998
      count_if 29
      count_loop 37
      func_ref_strategy 5
      func_ref_max 6
      func_ref_average 1
      func_num 16
    end

    trait :type2 do
      score 44.82215
      line 626
      size 18_992
      gzip_size 3021
      count_if 103
      count_loop 72
      func_ref_strategy 9
      func_ref_max 11
      func_ref_average 3
      func_num 17
    end

    trait :type3 do
      score 32.36735
      line 206
      size 3948
      gzip_size 804
      count_if 35
      count_loop 21
      func_ref_strategy 6
      func_ref_max 6
      func_ref_average 1
      func_num 5
    end

    trait :type4 do
      score 52.02475
      line 308
      size 7610
      gzip_size 1690
      count_if 67
      count_loop 32
      func_ref_strategy 7
      func_ref_max 7
      func_ref_average 1
      func_num 7
    end

    trait :type5 do
      score 35.20245
      line 574
      size 12_586
      gzip_size 2427
      count_if 66
      count_loop 82
      func_ref_strategy 7
      func_ref_max 7
      func_ref_average 1
      func_num 16
    end
  end
end

