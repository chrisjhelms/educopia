class ContentProviderAddAcronym < ActiveRecord::Migration
  def self.up 
    add_column "content_providers", "acronym", :string, :limit => 4    
    add_index :content_providers, :acronym;
  end
  
  def self.down
    remove_column "content_providers", "acronym"
  end
end
