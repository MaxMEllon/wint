class CreateSubmits < ActiveRecord::Migration
  def change
    create_table :submits do |t|
      t.integer :player_id, null: false
      t.string  :src_file,  null: false, default: ""
      t.string  :comment
      t.integer :number,    null: false
      t.integer :status,    null: false, default: 0
      t.boolean :is_active, null: false, default: true

      t.timestamps
    end
  end
end

