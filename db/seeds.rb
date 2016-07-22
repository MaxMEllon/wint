# coding: utf-8

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


if Rails.env == 'development'
  User.destroy_all
  League.destroy_all

  student = User.create(snum: 's00t000', name: '学生太郎', password: 'hoge')
  admin = User.create(snum: 'admin', name: '教授者太郎', password: 'hoge', category: 2)

  league = League.create(name: "test", start_at: Time.now - 5.day, end_at: Time.now + 5.day, limit_score: 100, change: 6, take: 6, try: 10000)

  Player.create(name: "participant", role: Player::ROLE_PARTICIPANT, league_id: league.id, user_id: student.id)
  Player.create(name: "auditor", role: Player::ROLE_AUDITOR, league_id: league.id, user_id: admin.id)
end

