class RefineUser < ActiveRecord::Migration
  def self.up
    add_column :users, :email, :string, :default => "", :null => false
    add_column :users, :first_name, :string, :default => "", :null => false
    add_column :users, :last_name, :string, :default => "", :null => false
    add_column :users, :rights, :string, :default => "view", :null => false  
    add_column :users, :content_provider_id, :integer
  end

  def self.down
    remove_column :users, :email
    remove_column :users, :first_name
    remove_column :users, :last_name
    remove_column :users, :rights
    remove_column :users, :content_provider_id
  end
end
