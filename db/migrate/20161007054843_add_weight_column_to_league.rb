class AddWeightColumnToLeague < ActiveRecord::Migration
  def change
    add_column :leagues, :weight, :string
  end
end
