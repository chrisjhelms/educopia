class FillAuStateTable < ActiveRecord::Migration
  def self.up
	AuState.reset(".") ;
  end

  def self.down
	puts "Can't revert to previous AuState table"; 
  end
end
