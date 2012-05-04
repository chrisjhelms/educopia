class AddStatesToAus < ActiveRecord::Migration
  
  def self.up 
    create_table "au_states", :force => true do |t|
      t.string   "name"
      t.text     "description"
      t.integer  "level"; 
      t.timestamps
    end
    add_column "archival_units", "au_state_id", :integer
    
  end
  
  def self.down
    remove_column "archival_units", "au_state_id"
    drop_table :au_states
  end
  
  
end
