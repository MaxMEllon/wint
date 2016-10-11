# == Schema Information
#
# Table name: leagues
#
#  id          :integer          not null, primary key
#  name        :string(255)      not null
#  start_at    :datetime         default(2014-10-24 15:06:30 +0000), not null
#  end_at      :datetime         default(2014-10-24 15:06:30 +0000), not null
#  limit_score :float            default(0.0), not null
#  is_analy    :boolean          default(FALSE), not null
#  data_dir    :string(255)      default(""), not null
#  rule_file   :string(255)      default(""), not null
#  is_active   :boolean          default(TRUE), not null
#  created_at  :datetime
#  updated_at  :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :league do
    id 1
    name 'テストリーグ'
    start_at Time.now - 5.day
    end_at Time.now + 5.day
    limit_score 150.0
    weight '1.0,1.5,1.5,1.0,1.0'
    data_dir "data/#{Rails.env}/001"
    change 7
    take 5
    try 10_000

    before :create do
      League.skip_callback(:create, :after, :after_create)
    end

    after :create do
      League.set_callback(:create, :after, :after_create)
    end
  end

  factory :league_model_test, class: League do
    id 1
    name 'テストリーグ'
    start_at Time.now - 5.day
    end_at Time.now + 5.day
    limit_score 150.0
    weight '1.0,1.5,1.5,1.0,1.0'
    data_dir "data/#{Rails.env}/001"
    change 7
    take 5
    try 10_000
  end
end

