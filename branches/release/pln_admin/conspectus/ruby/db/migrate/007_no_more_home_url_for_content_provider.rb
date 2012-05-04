class NoMoreHomeUrlForContentProvider < ActiveRecord::Migration
  def self.up
    remove_column :content_providers, :home_url  
  end

  def self.down
    add_column :content_providers, :home_url, :string
  end
end
