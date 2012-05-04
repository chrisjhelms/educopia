class AuOffline < ActiveRecord::Migration
  def self.up
    add_column :archival_units, :off_line, :boolean, :default => false
  end

  def self.down
    remove_column :archival_units, :off_line
  end
  
end
