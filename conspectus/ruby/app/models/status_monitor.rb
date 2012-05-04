class StatusMonitor 
  def self.auid_list_url
      Global.get('status_monitor_auid_list');
  end
  def self.au_status_url
      Global.get('status_monitor_au_status');
  end
 
  def self.active?
      au_status_url != "" && au_status_url != nil; 
  end
   
end
