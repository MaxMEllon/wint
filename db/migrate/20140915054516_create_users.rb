class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string  :snum,      null: false
      t.string  :name,      null: false
      t.integer :depart,    null: false, default: 0
      t.integer :entrance,  null: false, default: Time.new.year-2
      t.integer :category,  null: false, default: 0
      t.boolean :is_active, null: false, default: true
      t.string  :password_digest

      t.timestamps
    end
  end
end

