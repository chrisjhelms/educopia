class Globals < ActiveRecord::Migration
  
  def self.up 
    create_table "globals", :force => true do |t|
      t.string   "name"
      t.text     "value"
    end
    Global.update();
  end
  
  def self.down
    drop_table :globals
  end
  
  
end
