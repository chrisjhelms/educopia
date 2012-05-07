class AuStatusConnectionForArchives < ActiveRecord::Migration
  def self.up
    add_column :archives, :collection_status_url_pattern, :string
  end

  def self.down
    remove_column :archives, :collection_status_url_pattern
  end
end
