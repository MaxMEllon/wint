class RemoveColumnFromStrategy < ActiveRecord::Migration
  def change
    remove_column :strategies, :line
    remove_column :strategies, :size
    remove_column :strategies, :gzip_size
    remove_column :strategies, :count_if
    remove_column :strategies, :count_loop
    remove_column :strategies, :func_ref_strategy
    remove_column :strategies, :func_ref_max
    remove_column :strategies, :func_ref_average
  end
end
