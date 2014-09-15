class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.integer :user_id,   null: false
      t.integer :league_id, null: false
      t.string  :name,      null: false
      t.integer :role,      null: false, default: 0
      t.integer :submit_id, null: false
      t.boolean :is_active, null: false, default: true

      t.timestamps
    end
  end
end

