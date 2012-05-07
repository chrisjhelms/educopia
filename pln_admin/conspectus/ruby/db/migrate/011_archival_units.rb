class ArchivalUnits < ActiveRecord::Migration
  def self.up 
    create_table "archival_units"  do |t|
      t.integer  "collection_id"
      t.string   "param_values"
      t.timestamps
    end
    add_index :archival_units, :collection_id;
  end
  
  def self.down
    drop_table :archival_units
  end
end
