class ContentProviderAddPluginNone < ActiveRecord::Migration
  def self.up 
    add_column "content_providers", "placeholder_plugin_id", :integer
  end
  
  def self.down
    remove_column "content_providers", "placeholder_plugin_id"
  end
end
