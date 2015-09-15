class AddColumnLeague < ActiveRecord::Migration
  def change
    add_column :leagues, :compile_command, :string
    add_column :leagues, :exec_command, :string
  end
end
