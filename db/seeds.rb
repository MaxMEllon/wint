# coding: utf-8

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.destroy_all
League.destroy_all

User.create(snum: "s11t230", name: "玄馬史也", password: "hoge", password_confirmation: "hoge")
User.create(snum: "tmnghryk", name: "富永浩之", password: "hoge", password_confirmation: "hoge", category: 2)


