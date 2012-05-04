class MetadataHandlerForArchives < ActiveRecord::Migration
  def self.up
    add_column :archives, :create_url_pattern, :string
    add_column :archives, :update_url_pattern, :string
    add_column :archives, :show_url_pattern, :string
  end

  def self.down
    remove_column :archives, :create_url_pattern
    remove_column :archives, :update_url_pattern
    remove_column :archives, :show_url_pattern
  end
end
