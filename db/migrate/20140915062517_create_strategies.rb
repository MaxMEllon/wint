class CreateStrategies < ActiveRecord::Migration
  def change
    create_table :strategies do |t|
      t.integer :submit_id,  null: false
      t.float   :score,      null: false, default: 0
      t.integer :number,     null: false
      t.string  :analy_file, null: false, default: ""
      t.boolean :is_active,  null: false, default: true

      t.timestamps
    end
  end
end

