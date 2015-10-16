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
    name 'テストリーグ'
    limit_score 150.0
    is_analy false
    is_active true
    start_at '2015-09-01'
    end_at '2015-09-30'
    stock File.read("#{Rails.root}/spec/factories/data/001/rule/Stock.ini")
    header File.read("#{Rails.root}/spec/factories/data/001/rule/Poker.h")
    exec File.read("#{Rails.root}/spec/factories/data/001/rule/PokerExec.c")
    card File.read("#{Rails.root}/spec/factories/data/001/rule/CardLib.c")
    change 7
    take 5
    try 10_000

    factory :feature_league do
      stock "#{Rails.root}/spec/factories/data/001/rule/Stock.ini"
      header "#{Rails.root}/spec/factories/data/001/rule/Poker.h"
      exec "#{Rails.root}/spec/factories/data/001/rule/PokerExec.c"
      card "#{Rails.root}/spec/factories/data/001/rule/CardLib.c"
    end
  end
end

