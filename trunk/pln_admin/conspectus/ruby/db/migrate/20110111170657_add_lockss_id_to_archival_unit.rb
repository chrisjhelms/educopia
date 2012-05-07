class AddLockssIdToArchivalUnit < ActiveRecord::Migration
  def self.up
    add_column :archival_units, :lockss_au_id, :string
  end

  def self.down
    remove_column :archival_units, :lockss_au_id
  end
end
