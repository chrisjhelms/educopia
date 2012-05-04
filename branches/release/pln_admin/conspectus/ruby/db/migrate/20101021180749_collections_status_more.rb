class CollectionsStatusMore < ActiveRecord::Migration
  def self.up
    add_column :collection_status_items, :disk_usage, :float, :default => false
  end

  def self.down
    remove_column :collection_status_items, :disk_usage
  end
end
