# == Schema Information
#
# Table name: players
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  league_id  :integer          not null
#  name       :string(255)      not null
#  role       :integer          default(0), not null
#  submit_id  :integer          not null
#  is_active  :boolean          default(TRUE), not null
#  created_at :datetime
#  updated_at :datetime
#  data_dir   :string(255)      not null
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :player do
    user_id 1
    league_id 1
    name 'ほげ太郎'
    role 0
    submit_id 0
    is_active true
  end
end

