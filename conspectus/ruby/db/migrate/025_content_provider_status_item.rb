class ContentProviderStatusItem < ActiveRecord::Migration
   def self.up
    create_table :content_provider_status_items do |t|
      t.integer   "content_provider_id"
      t.string    "cache"
      t.integer   "size", :limit => 8, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :content_provider_status_items
  end
end
