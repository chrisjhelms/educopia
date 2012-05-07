class PluginParams < ActiveRecord::Migration
  def self.up 
    create_table "plugin_params"  do |t|
      t.integer  "plugin_id"
      t.string   "name"
      t.string   "kind"
      t.timestamps
    end
    add_index :plugin_params, :plugin_id;
  end
  
  def self.down
    drop_table :plugin_params
  end
end
