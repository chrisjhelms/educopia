class RenameReverseDns < ActiveRecord::Migration
  def self.up
    rename_column('content_providers', 'reverse_dns', 'plugin_prefix')
  end

  def self.down
    rename_column('content_providers', 'plugin_prefix', 'reverse_dns')
  end
end
