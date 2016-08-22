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
  factory :submit do
    id 1
    if Rails.env.test?
      data_dir { "#{Rails.root}/tmp/data/001/#{format('%04d', id)}/001" }
    else
      data_dir { "#{Rails.root}/public/data/001/#{format('%04d', id)}/001" }
    end
    comment 'コメント'
    number 1
    status 1
    is_active true

    before :create do
      Submit.skip_callback(:create, :after, :after_create)
    end

    after :create do
      Submit.set_callback(:create, :after, :after_create)
    end
  end
end

