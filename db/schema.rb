# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160727065609) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "leagues", force: :cascade do |t|
    t.string   "name",                                        null: false
    t.datetime "start_at",    default: '2016-08-17 17:21:37', null: false
    t.datetime "end_at",      default: '2016-08-17 17:21:37', null: false
    t.float    "limit_score", default: 0.0,                   null: false
    t.boolean  "is_analy",    default: false,                 null: false
    t.string   "data_dir",    default: "",                    null: false
    t.boolean  "is_active",   default: true,                  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "change"
    t.integer  "take"
    t.integer  "try"
  end

  create_table "players", force: :cascade do |t|
    t.integer  "user_id",                   null: false
    t.integer  "league_id",                 null: false
    t.string   "name",                      null: false
    t.integer  "role",       default: 0,    null: false
    t.integer  "submit_id",                 null: false
    t.boolean  "is_active",  default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "data_dir",                  null: false
  end

  create_table "strategies", force: :cascade do |t|
    t.integer  "submit_id",                        null: false
    t.float    "score",             default: 0.0,  null: false
    t.integer  "number",                           null: false
    t.boolean  "is_active",         default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "line"
    t.integer  "size"
    t.integer  "gzip_size"
    t.integer  "count_if"
    t.integer  "count_loop"
    t.integer  "func_ref_strategy"
    t.integer  "func_ref_max"
    t.integer  "func_ref_average"
    t.integer  "func_num"
  end

  create_table "submits", force: :cascade do |t|
    t.integer  "player_id",                 null: false
    t.string   "data_dir",   default: "",   null: false
    t.string   "comment"
    t.integer  "number",                    null: false
    t.integer  "status",     default: 0,    null: false
    t.boolean  "is_active",  default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "snum",                           null: false
    t.string   "name",                           null: false
    t.integer  "category",        default: 0,    null: false
    t.boolean  "is_active",       default: true, null: false
    t.string   "password_digest"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
