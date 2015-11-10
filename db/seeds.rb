# coding: utf-8

require 'factory_girl'
Dir[Rails.root.join('spec/factories/*.rb')].each { |f| require f }

User.destroy_all
League.destroy_all
Player.destroy_all
Submit.destroy_all

User.create(snum: "tmnghryk", name: "富永浩之", password: "hoge", password_confirmation: "hoge", category: 2)
User.create(snum: "s11t230", name: "玄馬史也", password: "hoge", password_confirmation: "hoge")

League.create FactoryGirl.attributes_for :league
Player.create FactoryGirl.attributes_for :player
# Submit.create FactoryGirl.attributes_for :submit

