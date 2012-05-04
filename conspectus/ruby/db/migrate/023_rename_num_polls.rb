class RenameNumPolls < ActiveRecord::Migration
  def self.up
    rename_column(:preservation_status_items, :num_polls, :num_recent_polls)
  end

  def self.down
    rename_column(:preservation_status_items, :num_recent_polls, :num_polls)
  end
end
