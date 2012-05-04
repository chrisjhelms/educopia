class DescriptionForPluginParams < ActiveRecord::Migration
  def self.up
    add_column :plugin_params, :descr, :string
  end

  def self.down
    remove_column :plugin_params, :descr
  end

end
