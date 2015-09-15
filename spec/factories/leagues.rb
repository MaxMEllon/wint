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
    rule_files "#{Rails.root}/spec/factories/rule.zip"
    compile_command 'gcc -O2 -I ${rule} ${src_file} ${rule}/PokerExec.c ${rule}/CardLib.c -DTYPE=5-7 -DTAKE=5 -DCHNG=7 -o ${exec_file}'
    exec_command '${exec_file} 10000 ${rule}/Stock.ini 0'

    factory :factory_league do
      data_dir "#{Rails.root}/spec/factories/data/001"
      rule_file "#{Rails.root}/spec/factories/data/001/rule/rule.json"
    end
  end
end
