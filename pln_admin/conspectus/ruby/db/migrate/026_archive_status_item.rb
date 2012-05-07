class ArchiveStatusItem < ActiveRecord::Migration
  def self.up
    create_table :archive_status_items do |t|
      t.integer   "archive_id"
      t.string    "cache"
      t.integer   "size", :limit => 8, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :archive_status_items
  end
end
