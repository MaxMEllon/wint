class AddAbcSizeToStrategy < ActiveRecord::Migration
  def change
    add_column :strategies, :abc_size, :float
    add_column :strategies, :statement, :integer
  end
end
