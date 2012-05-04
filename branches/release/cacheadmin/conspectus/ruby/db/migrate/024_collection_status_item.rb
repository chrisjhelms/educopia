class CollectionStatusItem < ActiveRecord::Migration
  def self.up
    create_table :collection_status_items do |t|
      t.integer   "collection_id"
      t.string    "cache"
      t.integer   "size", :limit => 8, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :collection_status_items
  end
end
