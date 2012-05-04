namespace :archive do
  require 'tasks/rake_option'
  require 'tasks/task_helper'
  include Task; 
  
  desc "list archives"; 
  task :list  => :environment do |t|
    if (start_task(t, {})) then 
     
      for a in  Archive.find(:all) do 
	puts "Archive: " + a.title + "\t" + "'" + a.description[0..20] + "...'"
      end  
    end
  end
  
  desc "destroy archive with given NAME";
  task :destroy  => :environment do |t|
    if (start_task(t, {'NAME' => nil})) then 
      a = nil; 
      name = @opts['NAME'];
      if (name != nil) then 
        a = Archive.find_by_title(name)
      end
      if (a.nil?) then 
        $stderr.puts "Must give valid Archive name";
        exit 1;
      end
      puts "destroy #{a.inspect}"
      a.destroy 
    end
  end

  desc "create archive with given NAME and DESCRiption"; 
  task :create  => :environment do |t|
    if (start_task(t, {'NAME' => nil, 
                       'DESCR' => nil})) then 
      a = nil;
      name = @opts['NAME'];
      descr = @opts['DESCR'] 
      if (name == nil || descr == nil) then
        $stderr.puts "Must give NAME, and a DESCRiption"
        exit 1; 
      end 
      a = Archive.new(:title => name, :description => descr); 
      a.save!
     end
  end

  desc "configure metadata editor"; 
  task :config_ma_editor  => :environment do |t|
    if (start_task(t, {'NAME' => nil, 
                       'CREATE' => nil, 
                       'UPDATE' => nil, 
                       'SHOW' => nil})) then 
      a = nil;
      name = @opts['NAME'];
      if (name == nil) then
        $stderr.puts "Must give NAME"
        exit 1; 
      end 
      a = Archive.find_by_title(name); 
      if (a.nil?) then 
        $stderr.puts "Archive \'#{name}\' not found"; 
        exit 1;
      end
      puts "REDIFINING metadata editor for #{a.inspect}"
      a.metadata_url_pattern(:create, @opts['CREATE']) 
      a.metadata_url_pattern(:update, @opts['UPDATE']) 
      a.metadata_url_pattern(:show, @opts['SHOW']) 
      a.save!
     end
 end
 
  desc "create/update from yml file in config" 
  task :reset => :environment do |t|
    if (start_task(t, {})) then 
      Archive.reset(); 
    end
  end
  
end
