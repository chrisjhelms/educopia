class DeleteAuStateIngest < ActiveRecord::Migration
 
  def self.up
      st = AuState.get("ingest"); 
      if (st) then st.destroy; end 
  end

  def self.down
     AuState.new(:name => "ingest", 
                 :level => AuState.get("test").level + 1, 
                 :irreversible => 1, 
                 :description => "ingested but not fully replicated").save! 
  end
end
