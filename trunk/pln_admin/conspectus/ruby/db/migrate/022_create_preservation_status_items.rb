class CreatePreservationStatusItems < ActiveRecord::Migration
  def self.up
    remove_column :archives, :collection_status_url_pattern
    create_table :preservation_status_items do |t|
      t.integer   "archival_unit_id"
      t.string    "cache"
      t.string    "hostname"
      t.integer   "ui_port"
      t.float     "disk_usage"
      t.integer   "size", :limit => 8
      t.datetime 	"last_crawl"
      t.string 	  "last_crawl_result"
      t.datetime 	"last_crawl_attempt"
      t.datetime 	"last_poll"
      t.integer 	"num_polls"
      t.float     "agreement" 
      t.timestamps
    end
    Global.set("status_monitor", "");
  end

  def self.down
    add_column :archives, :collection_status_url_pattern, :string
    
    drop_table :preservation_status_items
    
    Global.find_by_name("status_monitor").destroy
  end
end
