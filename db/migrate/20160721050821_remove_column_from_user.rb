class RemoveColumnFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :depart
    remove_column :users, :entrance
  end
end
