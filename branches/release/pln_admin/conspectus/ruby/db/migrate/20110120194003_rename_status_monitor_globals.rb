class RenameStatusMonitorGlobals < ActiveRecord::Migration
  def self.up
    Global.set('status_monitor_au_status', Global.get('status_monitor')); 
    Global.set('status_monitor_auid_list', nil); 
    Global.find_by_name("status_monitor").destroy
  end
  
  def self.down
    Global.set('status_monitor', Global.get('status_monitor_au_status')); 
    Global.find_by_name("status_monitor_au_status").destroy
    Global.find_by_name("status_monitor_uid_list").destroy
  end
end
