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
  path = "data/#{Rails.env}/001"

  factory :player do
    id 1
    user_id 1
    name '北海太郎'
    data_dir "#{path}/0001"
    role 0
    submit_id 1

    before :create do
      Player.skip_callback(:create, :after, :after_create)
    end

    after :create do
      Player.set_callback(:create, :after, :after_create)
    end

    factory :player1 do
      id 1
      name 'player1'
      data_dir "#{path}/0001"
      submit_id 1
    end

    factory :player2 do
      id 2
      name 'player2'
      data_dir "#{path}/0002"
      submit_id 2
    end

    factory :player3 do
      id 3
      name 'player3'
      data_dir "#{path}/0003"
      submit_id 3
    end

    factory :player4 do
      id 4
      name 'player4'
      data_dir "#{path}/0004"
      submit_id 4
    end

    factory :player5 do
      id 5
      name 'player5'
      data_dir "#{path}/0005"
      submit_id 5
    end
  end

  factory :player_model_test, class: Player do
    id 1
    user_id 1
    name '北海太郎'
    data_dir "#{path}/0001"
    role 0
    submit_id 1
  end
end

