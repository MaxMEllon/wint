class AddColumnSubmit < ActiveRecord::Migration
  def change
    add_column :submits, :analysis_file, :string
  end
end
