class AddRuleToLeague < ActiveRecord::Migration
  def change
    add_column :leagues, :change, :integer
    add_column :leagues, :take, :integer
    add_column :leagues, :try, :integer
    remove_column :leagues, :rule_file
  end
end
