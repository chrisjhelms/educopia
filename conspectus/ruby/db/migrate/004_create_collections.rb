class CreateCollections < ActiveRecord::Migration
  def self.up
    create_table "collections", :force => true do |t|
      t.integer  "archive_id"
      t.integer  "plugin_id"
      t.string   "title"
      t.text     "description"
      t.string   "base_url"
      t.timestamps
    end
    add_index :collections, :archive_id;
    add_index :collections, :plugin_id;
    add_index :collections, :title;
  end

  def self.down
    drop_table :collections
  end
end
