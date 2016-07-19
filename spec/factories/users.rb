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
    snum 's00t000'
    name '北海太郎'
    password 'hoge'
    password_confirmation 'hoge'
    depart 0
    entrance 2011
    is_active true

    factory :student do
      category 0
    end

    factory :admin do
      category 2
    end
  end
end

