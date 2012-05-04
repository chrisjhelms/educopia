class Retirement < ActiveRecord::Migration
  def self.up
    add_column :collections, :retired, :boolean, :default => false
    add_column :plugins, :retired, :boolean, :default => false
    add_column :content_providers, :retired, :boolean, :default => false
    Global.set("retired_plugin_url", "") 
  end

  def self.down
    remove_column :collections, :retired
    remove_column :plugins, :retired
    remove_column :content_providers, :retired
    Global.find_by_name("retired_plugin_url").destroy
  end
end
