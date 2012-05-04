class CreateArchives < ActiveRecord::Migration
  def self.up
    create_table "archives", :force => true do |t|
      t.string   "title"
      t.text     "description"
      t.timestamps
    end
    add_index :archives, :title
  end
  
  def self.down
    drop_table :archives
  end
end
