namespace :collection do
  require 'find'
  require 'csv'
  require 'uri'

  require 'rexml/document'
  
  require 'tasks/rake_option'
  require 'tasks/task_helper'
  include Task; 
  
  desc "set base_url of collection, even if it has archival units" 
  task :set_base_url => :environment do |t|
    if (start_task(t, {'ID' => "", 'BASE_URL' => ""})) then
      c = Collection.find(@opts['ID']) if @opts['ID']
      if (c == nil) then  
        $stderr.puts "Must give valid collection ID"
        exit 1;
      end
      b = @opts['BASE_URL']
      buri = nil
      if (b != nil) then 
        buri = URI::parse(b)
      end
      if (buri == nil || 
          buri.class!= URI::HTTP || 
         !buri.absolute?) then  
        $stderr.puts "Must give valid collection BASE_URL"
        exit 1;
      end
      c.base_url= b; 
      c.archival_units.each  { |au| 
            au.reset_signature(b); 
            au.save(false)
      }
      c.save!
      end   
  end
  
  desc "mark all aus in collection  as offline / base_url available = false"
  task :offline => :environment do |t|
     do_on_off_task(:offline, t); 
  end
  
  desc "mark all aus in collection  as online / base_url available = false"
  task :online => :environment do |t|
     do_on_off__task(:on_line, t)
  end

  def do_on_off_task(what, t) 
    if (start_task(t, {'ID' => ""})) then
      c = Collection.find(@opts['ID'])
      offline = (what == :offline)
      if (c != nil) then begin 
          ArchivalUnit.transaction do
            c.offline_aus!(offline)
          end
          puts "Set all archival units of (id #{c.id}) #{c.title} to offline = #{offline}" ;       
        rescue  Exception => e; 
          $stderr.puts e.message; 
          $stderr.puts "Returning  all archival units in collection to orginal offline state"; 
        end
      else 
        $stderr.puts "Must give valid collection ID"
        exit 1;
      end 
    end
  end
  
  desc "find collection id from PLUGIN,BASEURL parameters"; 
  task :find  => :environment do |t|
    if (start_task(t, {'PLUGIN' => nil, 'BASEURL' => nil})) then 
      plugin = @opts['PLUGIN']
      base_url = @opts['BASEURL']
      if (plugin.nil?) then 
        $stderr.puts "Must give PLUGIN parameter"
        exit 1;
      end
      if (base_url.nil?) then 
        $stderr.puts "Must give BASE_URL parameter"
        exit 1;
      end
      cols = Collection.find_by_plugin_baseurl(plugin, base_url);
      if cols.empty? then 
        puts "No collection for plugin '#{plugin}' and '#{base_url}'";
      else 
        for col in cols do 
          puts col.toStr; 
        end
      end
    end 
  end 
  
  desc "set remote collection id from LOCALID,REMOTEID parameters"; 
  task :set_remote_id  => :environment do |t|
    if (start_task(t, {'LOCALID' => nil, 'REMOTEID' => nil})) then 
      id = @opts['LOCALID']
      remote_id = @opts['REMOTEID']
      begin 
        col = Collection.find(id); 
        raise "Can't find collection with id #{id}" unless col; 
        col.remote_id = remote_id;
        col.save! 
        puts col.toStr
      rescue 
        puts "ERROR: #{$!}";
      end
    end 
  end 
  
  desc "create/update collections from csv"; 
  task :csv_get  => :environment do |t|
    if (start_task(t, {'FILE' => nil, 
                       'CREATE' =>  "true", 
                       'CREATE_PLUGIN' =>  "false", 
                       'ARCHIVE' => nil})) then 
      create = @opts['CREATE'] == "true";
      create_plugin = @opts['CREATE_PLUGIN'] == "true";
      archive = @opts['ARCHIVE'];
      if (!archive.nil?) then 
        archive = Archive.find_by_title(archive);
      end
      if (create) then 
        if (archive.nil?) then 
          $stderr.puts "Must give valid ARCHIVE"; 
          exit(1); 
        end
      end
      puts "Will " + ((create) ? "create/update" : "update") + " collections in archive #{archive.title}\n";
      
      file = @opts['FILE'];
      if (file.nil?) then 
        $stderr.puts "Must give FILE parameter"
        exit 1;
      end
      
      @contents = CSV.read(file); 
      @header= @contents.shift; 
      for entry in @contents do      
        begin
          @entry = {}; i = 0; @header.each { |h| 
              @entry[h] = entry[i]; i = i + 1;
          } 
          id, plugin_name, base_url, title, description =  [@entry['id'], @entry['plugin_name'], @entry['base_url'], @entry['title'], @entry['description']]
          puts [id, plugin_name, base_url, title].inspect; 
          begin 
            id = Integer(id); 
          rescue
            raise "#{id} not an integer"
          end 
          if (plugin_name.nil?) then 
            raise "empty plugin_name";
          end
          plugin = Plugin.find_by_name(plugin_name); 
          if (plugin.nil? && create_plugin) then 
            splits = plugin_name.split("."); 
            cp_name = [splits[0], splits[1]].join(".")
            cp = ContentProvider.find_by_plugin_prefix(cp_name); 
            if (cp.nil?) then 
              raise "could not find content provider for plugin prefix #{cp_name}"
            else 
              plugin = Plugin.get(plugin_name, cp); 
              if (!plugin.nil?) then 
                puts "CREATE: plugin #{plugin.toStr}";
              end
            end
          end 
          if (plugin.nil?) then
            raise "could not find plugin #{plugin_name}"; 
          end
            
          cols = Collection.find_by_plugin_baseurl(plugin_name, base_url); 
          # must make unique with title 
          if (cols.empty?) then 
            if (create) then
              cols[0] = Collection.new(:title => title, 
                                       :base_url => base_url, 
                                       :plugin => plugin,
                                       :description => description, 
                                       :archive => archive, 
                                       :remote_id => id); 
              cols[0].save!;
              puts "CREATE: collection #{cols[0].toStr}";
            else 
              raise "could not find collection with base_url #{base_url} and plugin #{plugin_name}"; 
            end 
          end
          
        rescue Exception => e 
          #$stderr.puts e.backtrace;
          $stderr.puts "ERROR: #{$!}";
          $stderr.puts "     : " + [id, plugin_name, base_url, title].inspect; 
          
        end 
      end
    end
  end  
  
  desc "set description from REMOTE_ID,DESCR parameters" 
  task :set_description => :environment do |t|
    if (start_task(t, {'REMOTEID' => nil, 'DESCR' => nil})) then 
      remoteid = @opts['REMOTEID'];
      descr = @opts['DESCR'];
      if (remoteid.nil? || descr.nil?) then 
        puts "Must give REMOTEID and DESCR parameters"
        exit 1;
      end
      begin 
        cols = Collection.find(:all, :conditions => { :remote_id => remoteid}); 
        if cols.empty? then 
          raise "No collection found with remote_id #{remoteid}";
        end
        for col in cols do
          col.description = descr; 
          if (!col.save) then 
            puts "WARNING: could not save decription\n\t#{c.inspect}"
          end
        end
      rescue 
        puts "ERROR: #{$!}";
      end 
    end
  end  
  
end
