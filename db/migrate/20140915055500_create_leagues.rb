class CreateLeagues < ActiveRecord::Migration
  def change
    create_table :leagues do |t|
      t.string   :name,        null: false
      t.datetime :start_at,    null: false, default: Time.new
      t.datetime :end_at,      null: false, default: Time.new
      t.float    :limit_score, null: false, default: 0
      t.boolean  :is_analy,    null: false, default: false
      t.string   :src_dir,     null: false, default: ""
      t.string   :rule_file,   null: false, default: ""
      t.boolean  :is_active,   null: false, default: true

      t.timestamps
    end
  end
end

