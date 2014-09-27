class AddAndRenameColumn < ActiveRecord::Migration
  def change
    rename_column :leagues, :src_dir, :data_dir
    rename_column :submits, :src_file, :data_dir
    add_column :players, :data_dir, :string, null: false
  end
end
