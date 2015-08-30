# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  snum            :string(255)      not null
#  name            :string(255)      not null
#  depart          :integer          default(0), not null
#  entrance        :integer          default(2012), not null
#  category        :integer          default(0), not null
#  is_active       :boolean          default(TRUE), not null
#  password_digest :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    snum "MyString"
    name "MyString"
    password_digest "MyString"
    depart 1
    entrance 1
    category 1
    is_active false
  end
end
