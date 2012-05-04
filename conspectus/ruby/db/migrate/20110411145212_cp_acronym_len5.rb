class CpAcronymLen5 < ActiveRecord::Migration
  def self.up
    change_column "content_providers", "acronym", :string, :limit => 5    
  end

  def self.down
    change_column "content_providers", "acronym", :string, :limit => 4    
  end
end
