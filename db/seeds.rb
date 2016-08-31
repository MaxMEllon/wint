# coding: utf-8

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'factory_girl'
Dir[Rails.root.join('spec/factories/*.rb')].each {|f| require f}
require './spec/support/action_helper.rb'

if Rails.env == 'development'
  include ActionHelper
  include FactoryGirl::Syntax::Methods
  User.destroy_all
  League.destroy_all

  student = FactoryGirl.create(:student, snum: 's00t000')
  admin = FactoryGirl.create(:admin, snum: 's99t999')

  league = FactoryGirl.create(:league, is_analy: true)
  create_strategies(league)
  `rm -rf #{Rails.root}/public/data/001`
  `cp -r #{Rails.root}/tmp/data/001 #{Rails.root}/public/data/001`
end

