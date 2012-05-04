class AuStateReversibleFlag < ActiveRecord::Migration
  def self.up
     add_column(:au_states, :irreversible, :boolean, :default => true);
  end

  def self.down
    remove_column :au_states, :irreversible    
  end
end
