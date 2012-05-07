namespace :db do
  
  require 'tasks/rake_option'
  require 'tasks/task_helper'
  include Task; 
  
  DATA_TABLES = "users,archives,content_providers,collections,archival_units,plugins,preservation_status_items";
  
  desc "redo => backup drop create migrate"
  task :redo => %w(db:backup db:drop db:create db:migrate) 
  
  desc "dump database to file"
  task :backup  do |t|
    if (start_task(t, { 'BACKUP_DIR' => "~/db_backups", 
                        'LABEL' => "", 
                        'TABLES' => ""})) then 
      @backup_dir = @opts[ 'BACKUP_DIR']; 
      @dbtables = @opts[ 'TABLES'].split(",")
      @label =  "#{@opts[ 'LABEL']}";
      if (!system("mkdir -p #{@backup_dir}")) then
        $stderr.puts "could not create #{@dbbackup_dir}"
        exit(1);
      end
      timestamp = Time.now.utc.strftime('%Y-%m-%d-%H%M%S')
      table_list = (@dbtables.empty?) ? "" : ("_" + @dbtables.join(":"));
      if (@label != "") then 
        @file = File.join(@backup_dir, "#{@label}#{table_list}.sql.gz");
      else
        @file = File.join(@backup_dir, "#{@host}#{@dbase.config[:database]}_#{timestamp}#{table_list}.sql.gz");
      end
      cmd =  "#{@dbase.dumpcmd(@dbtables)} | gzip > #{@file}"   
      task_trace t, "writing file: #{@file}"
      ret = system(cmd);  # TODO: exit code is set unreliable  
      #puts "#{cmd}"; 
    end   
  end  
  
  desc "import database file" 
  task :import  do |t|
    if (start_task(t, { 'FILE' => ""})) then 
      @file = @opts[ 'FILE']
      if (@file != "") then 
        cmd =  "#{@dbase.importcmd(@file)}"   
        task_trace t,  "#{cmd}"; 
        task_trace t,  "importing from file: #{@file}"
        @ret = system(cmd);  # TODO: exit code is set unreliable  
      else 
        task_trace t,  "must give FILE parameter"
      end 
    end   
  end  
  
  desc "optimize database default tables or the the ones listed in TABLES parameter"
  task :optimize  do |t|
    if (start_task(t, {'TABLES' => DATA_TABLES})) then                        
      @dbtables = @opts['TABLES'].split(",")
      @dbase.optimize(@dbtables); 
    end
  end
  
  desc "print statistics"; 
  task :info  do |t|
    if (start_task(t, {'TABLES' => DATA_TABLES})) then                        
      @dbtables = @opts['TABLES'].split(",")
      for tbl in @dbtables do
        begin 
          cmd = "SELECT COUNT(*) FROM #{tbl}";
          n =  ActiveRecord::Base.connection.select_one(cmd)["COUNT(*)"]
          task_trace t,  "#{n}\t#{tbl}"; 
        rescue Exception 
          task_trace t,  "** ERROR: no active record for #{tbl} table"; 
          @ret = 1;
        end 
      end
    end
  end 
  
end 
