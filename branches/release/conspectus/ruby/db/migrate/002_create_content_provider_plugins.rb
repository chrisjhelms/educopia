class CreateContentProviderPlugins < ActiveRecord::Migration
  def self.up
    create_table "content_providers"  do |t|
       t.string   "name"
       t.string   "home_url"
       t.string   "reverse_dns"
       t.timestamps
   end
   add_index :content_providers, :name;
   
   create_table "plugins", :force => true do |t|
      t.integer  "content_provider_id"
      t.string   "name"
      t.timestamps
   end  
   add_index :plugins, :content_provider_id;
  end

  def self.down
    drop_table :content_providers
    drop_table :plugins
  end
end
