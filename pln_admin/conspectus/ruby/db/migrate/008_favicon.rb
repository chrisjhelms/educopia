class Favicon < ActiveRecord::Migration
  def self.up
    add_column :content_providers, :icon_url, :string
  end

  def self.down
     remove_column :content_providers, :icon_url 
  end

end
