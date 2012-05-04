class CollectionAddRemoteId < ActiveRecord::Migration
  def self.up 
    add_column "collections", "remote_id", :integer
  end
  
  def self.down
    remove_column "collections", "remote_id"
  end
end
