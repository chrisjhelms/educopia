namespace :status do
  require 'tasks/rake_option'
  require 'tasks/task_helper'
  include Task;
  
  # update status of all archival_units 
  # then propgate status info to collections and content_providers 
  desc "update preservation status from data in status monitor (LOCKSS cachemanager)"
  task :update  => [:init, :update_auids, :clear, :retrieve, :propagate] do |t|  
  end
  
  # update lockssausids 
  desc "update lockssauids from json producing url"
  task :update_auids =>  [:init]  do |t| 
    if (start_task(t, {})) then 
      @lockssauids = NetData.new(@auid_list_url, "get").convert(LockssAu)
      n = 0; 
      e = 0; 
      for id in @lockssauids do
        n = n + 1;
        if (!id.attach_to_archival_unit) then 
          e = e + 1
          task_trace t, "ERROR: Can't attach: '#{id.lockss_au_id}'"
          task_trace t, "       base_url=#{id.base_url}"; 
          task_trace t, "       params=#{id.extra_params}"; 
        end
      end
      task_trace t, "Succesfully Attached #{n-e} archival units"; 
      task_trace t, "Attachment ERRORS for #{e} archival units"; 
    end
  end

  # clear all status information 
  desc "update preservation status from data in status monitor (LOCKSS cachemanager)"
  task :clear=> [:environment] do |t|
    if (start_task(t, {"FORCE" => "false"})) then
      if (!StatusMonitor.active?) then
        if  (@opts['FORCE'] != "true" ) then 
          task_trace t, "No StatusMonitor definition in Globals"; 
          task_trace t, "To force clearing out status information rerun with FORCE=true"
          return;
        end 
      end
      Rake::Task['db:backup'].invoke
      delete_status(t, ArchiveStatusItem, 
                       ContentProviderStatusItem, 
                       CollectionStatusItem,
                       PreservationStatusItem);
    end
  end
  
  # retrieve status of all archival_units 
  desc "retrieve preservation status data from status monitor (LOCKSS cachemanager)"
  task :retrieve  => [:init] do |t|
    if (start_task(t, { "MAXERROR" => "-1"})) then 
      maxerr = Integer(@opts["MAXERROR"]); 
      nerr = 0; 
      task_trace t,  "To avoid inconsistent data please run :propagate task after successfull completion"
      @archival_units =  ArchivalUnit.find(:all, :conditions => "`lockss_au_id` != 'NULL'")
      @archival_units.each { |au| 
        begin 
          repl = PreservationStatusItem.update_archival_unit(au, nil, @au_status_url)
          task_trace(t, "WARNING #{au.toTxt} - Replication #{repl}") if  repl <= 0       
        rescue Exception => e
          task_trace t, "ERROR: #{au.toTxt} - Processing Status '#{e}''"
          nerr = nerr + 1;
          # will go forever if MAXERR < 0 
          if ((maxerr - nerr) == 0) then 
            task_trace(t, "ERROR Archival Units - Too Many")
            break;
          end 
        end
      }
      task_trace(t, "ERROR Archival Units - #{nerr}")
    end
  end
  
  # retrieve status of one archival_units 
  desc "retrieve preservation status from data in status monitor (LOCKSS cachemanager)"
  task :retrieve_one  => [:init] do |t|
    if (start_task(t, { "AUID" => ""})) then 
      if (@opts['AUID'] == "") then 
        task_trace t, "Must define AUID"; 
      else 
        au_id = Integer(@opts["AUID"]);
        task_trace t,  "To avoid inconsistent data please run :propagate task after successfull completion"
        au =  ArchivalUnit.find(au_id)
        begin 
          repl = PreservationStatusItem.update_archival_unit(au, nil, @au_status_url)
          task_trace(t, "WARNING #{au.toTxt} - Replication #{repl}") if  repl <= 0       
        rescue Exception => e
          task_trace t, "ERROR: #{au.toTxt} - Processing Status '#{e}''"
          raise e
        end
      end
    end
  end
  
  # propgate status info to collections, archives, and content_providers 
  desc "update preservation status from data in status monitor (LOCKSS cachemanager)"
  task :propagate  => :environment do |t|
    if (start_task(t)) then 
      if (monitor?) then 
        begin 
          task_trace t, "Propagating Status Data to Collections\n"; 
          Collection.find(:all).each { |cp| cp.update_status(); }
          task_trace t, "Propagating Status Data to ContentProviders"; 
          ContentProvider.find(:all).each { |cp| cp.update_status(); }
          task_trace t, "Propagating Status Data to Archives"; 
          Archive.find(:all).each { |cp| cp.update_status(); }
        rescue Exception => e
          task_trace t, "ERROR: Processing Status #{e.inspect}"
          delete_status(t, ArchiveStatusItem, 
                        ContentProviderStatusItem, 
                        CollectionStatusItem);
        end 
      end
    end
  end
    
  desc "initialize status monitor urls"
  task :init => [:environment] do |t| 
    opts = {"AUID_LIST_URL" =>  StatusMonitor.auid_list_url, "AU_STATUS_URL" => StatusMonitor.au_status_url };
    if (start_task(t, opts)) then 
      @au_status_url = @opts["AU_STATUS_URL"]; 
      @auid_list_url = @opts["AUID_LIST_URL"]; 
      if (@auid_list_url == "" || @au_status_url == "") then
        task_trace t, "Must define AUID_LIST_URL and AU_STATUS_URL"; 
        exit(1);  
      end 
    end
  end

  def delete_status(t, *klasses) 
    klasses.each  { |k| 
      task_trace t, "Deleting all #{k.name}";
      k.delete_all;
    }
  end
  
  def monitor?
    if (!StatusMonitor.active?) then
      task_trace t, "No StatusMonitor: nothing to retrieve"
      return false;     
    end 
    return true;
  end
  
end
