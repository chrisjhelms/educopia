namespace :conspectus do
  require 'find'
  
  require 'rexml/document'
  
  require 'tasks/rake_option'
  require 'tasks/task_helper'
  include Task; 
  
  desc "update some or all: globals, archives, content_providers, users "
  task :update  => :environment do |t|
    if (start_task(t, {"INSTANCE" => nil, 
                        'USERS' => 'false',
                        'CONTENT_PROVIDERS' => 'true', 
                        'ARCHIVES' => 'true', 
                        'GLOBALS' => 'true' })) then 
      inst = @opts["INSTANCE"]; 
      if (!inst.nil?) then 
        puts "Updating #{inst}"; 
        Global.update(inst) if (@opts['GLOBALS'] == 'true');
        Archive.update(inst) if (@opts['ARCHIVES'] == 'true')
        ContentProvider.update(inst) if (@opts['CONTENT_PROVIDERS'] == 'true')
        begin 
          User.update(inst) if (@opts['USERS'] == 'true');
        rescue
          puts "WARNING: " + $!;
        end 
      else
        $stderr.puts "Must give INSTANCE parameter"
        exit 1; 
      end
    end
  end
  
  desc "init au_states and run update"
  task :init  => [:environment] do |t|
    if (start_task(t, {"INSTANCE" => nil})) then 
      AuState.reset("./");
    end
  end
  
end
