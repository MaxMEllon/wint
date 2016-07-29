class AddAnalysisColumnToStrategy < ActiveRecord::Migration
  def change
    add_column :strategies, :line, :integer
    add_column :strategies, :size, :integer
    add_column :strategies, :gzip_size, :integer
    add_column :strategies, :count_if, :integer
    add_column :strategies, :count_loop, :integer
    add_column :strategies, :func_ref_strategy, :integer
    add_column :strategies, :func_ref_max, :integer
    add_column :strategies, :func_ref_average, :integer
    add_column :strategies, :func_num, :integer
    remove_column :strategies, :analy_file
  end
end
