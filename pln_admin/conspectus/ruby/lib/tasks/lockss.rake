namespace :lockss do
  require 'find'
  
  require 'tasks/rake_option'
  require 'tasks/task_helper'
  include Task; 
  
  # imports plugin definition from plugin xml files 
  # TODO fix chop 
  desc "import plugins from file/directory"
  task :import_plugins  => :environment do |t|
    if (start_task(t, { 'PLUGINS' => "", "CHOPSLASH" => "1"})) then 
      if (@opts["PLUGINS"].empty?) then 
        raise "must give PLUGINS paramater"; 
      end
      LockssPlugin.find_and_create(@opts['PLUGINS'], @opts[ 'CHOPSLASH'].to_i); 
    end
  end
  
 
  # imports collection information from title database 
  # create archival units if DO_AUS paameter is true  
  # and sets state according to AU_STATE parameter 
  desc "ingest collections/archival unit information from title database " 
  task :import_content_defs => :environment do |t| 
    if (start_task(t, { 'FILE' => "", 
                        'ARCHIVE' => "", 
                        'N_PROP_LEVEL' => "1", 
                        'DO_COLLS' => "true",
                        'DO_AUS' => 'false', 
                        'AU_STATE' => 'preserved'})) then 
      arch = Archive.find_by_title(@opts['ARCHIVE']); 
      if (arch.nil?) then 
        $stderr.puts "ARCHIVE \'#{@opts['ARCHIVE']}\' not defined"
        exit 1; 
      end
      do_aus = @opts['DO_AUS'] == "true"; 
      if (do_aus) then 
        au_state = AuState.get(@opts['AU_STATE'])
        if (au_state.nil?) then 
          $stderr.puts "#{@opts['AU_STATE']} is not a valid state"; 
          exit(1);
        end
      end
      do_colls =  @opts['DO_COLLS'] == "true"; 
      n_level =  @opts['N_PROP_LEVEL'].to_i; 
      if (n_level < 1) then 
        $stderr.puts "N_PROP_LEVEL must be >= 1"; 
        exit(1); 
      end
      file = @opts['FILE']; 
      
      LockssTitleDb.create_from_file(arch, file, do_colls, do_aus, au_state, n_level);
    end 
  end  
  
  
  # sets the au_state of archival units described in title database 
  desc "set au_state of archival units defined in title database " 
  task :set_au_states => :environment do |t| 
    if (start_task(t, { 'FILE' => "", 
                        'N_PROP_LEVEL' => "1", 
                        'AU_STATE' => 'preserve'})) then 
      au_state = AuState.get(@opts['AU_STATE'])
      if (au_state.nil?) then 
        $stderr.puts "#{@opts['AU_STATE']} is not a valid state"; 
        exit(1);
      end
      n_level =  @opts['N_PROP_LEVEL'].to_i; 
      if (n_level < 1) then 
        $stderr.puts "N_PROP_LEVEL must be >= 1"; 
        exit(1); 
      end
      file = @opts['FILE']; 
      LockssTitleDb.set_au_state_from_file(file, au_state, n_level);
    end   
  end  
  
end 
