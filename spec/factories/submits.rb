# == Schema Information
#
# Table name: submits
#
#  id         :integer          not null, primary key
#  player_id  :integer          not null
#  data_dir   :string(255)      default(""), not null
#  comment    :string(255)
#  number     :integer          not null
#  status     :integer          default(0), not null
#  is_active  :boolean          default(TRUE), not null
#  created_at :datetime
#  updated_at :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  path = "#{Rails.root}/spec/factories/data/001/source/0001/001/"

  factory :submit do
    player_id 1
    data_dir File.read(path + 'success.c')
    comment 'hoge狙い'
  end
end
