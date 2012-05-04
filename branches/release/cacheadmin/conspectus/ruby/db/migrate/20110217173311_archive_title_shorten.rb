class ArchiveTitleShorten < ActiveRecord::Migration
  def self.up
	change_column(:archives, :title, :string, :limit => 5)
  end

  def self.down
	change_column(:archives, :title, :string) 
  end
end
