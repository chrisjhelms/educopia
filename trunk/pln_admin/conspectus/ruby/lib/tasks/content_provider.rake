namespace :content_provider do
  require 'find'
  
  require 'rexml/document'
  
  require 'tasks/rake_option'
  require 'tasks/task_helper'
  include Task; 
  
  desc "list content providers"; 
  task :list  => :environment do |t|
    if (start_task(t, {})) then 
      @cps = ContentProvider.find(:all)
      for cp in @cps do 
        puts "#{cp.acronym} \t #{cp.plugin_prefix} \t #{cp.name}"
      end  
    end
  end
  
  desc "mark all collection as offline"
  task :offline => :environment do |t|
    do_cp_on_offline_task(:offline, t); 
  end
  
  desc "mark all collection as online"
  task :online => :environment do |t|
    do_cp_on_offline_task(:on_line, t)
  end
  
  desc "change state of all AUS in old state to new state"
  task :change_au_states => :environment do |t|
    if (start_task(t, {'ACRONYM' => nil, 'PLUGIN' => nil, 'OLD' => '', 'NEW' => ''})) then 
      c = content_provider_get(@opts)
      old = task_get_au_state('OLD', @opts) 
      new = task_get_au_state('NEW', @opts) 
      if (c != nil && old != nil && new != nil) then 
         begin 
          ArchivalUnit.transaction do
            c.change_state_aus!(old, new, true); 
          end
          puts "Moving all archival units with au_state #{old.name} to au_state #{new.name}" ;       
        rescue  Exception => e; 
          $stderr.puts e.message; 
          $stderr.puts "Returning  all archival units in all collections to orginal au state"; 
        end
      end
    end 
  end
  
  desc "retire all collections"
  task :retire => :environment do |t|
    do_cp_un_retire_task(:retire, t); 
  end
  
  desc "mark all collection as online"
  task :unretire => :environment do |t|
    do_cp_un_retire_task(:unretire, t); 
  end
  
  def do_cp_un_retire_task(what, t) 
    if (start_task(t, {'ACRONYM' => nil, 'PLUGIN' => nil})) then 
      cp = content_provider_get(@opts)
      if (cp != nil) then 
        begin
          retired_opt = (what == :retire);
          Collection.transaction do
            Plugin.transaction do
              cp.plugins.each do |p| 
                p.collections.each do |c| 
                  c.retired = retired_opt; 
                  puts "#{t}: /colections/#{c.id}\t#{c.title}";
                  c.save!
                end
                p.retired = retired_opt; 
                puts "#{t}: /plugins/#{p.id}\t#{p.name}";
                p.save!
              end
            end
          end
          puts (retired_opt ? "Retiring" : "Unretiring" ) + " all collections and plugins for content provider #{cp.acronym}"        
        rescue Exception => e; 
          $stderr.puts e.message; 
          $stderr.puts "Returning collections and plugins to old retirement state"; 
        end 
      end
    end
  end

  desc "destroy content provider with given NAME or PLUGIN prefix"; 
  task :destroy  => :environment do |t|
    if (start_task(t, {'ACRONYM' => nil, 'PLUGIN' => nil})) then 
      cp = content_provider_get(@opts); 
      if (cp) then 
        puts "destroy #{cp.inspect}"
        cp.destroy
      end 
    end
  end
  
  desc "destroy_aus aus in given states"
  task :destroy_aus => :environment do |t|
    if (start_task(t, {'ACRONYM' => nil, 'PLUGIN' => nil, 'STATES' => ''})) then 
      cp = content_provider_get(@opts); 
      states = task_get_au_states('STATES', @opts); 
      if (cp && !states.empty?) then 
        puts "destroy aus in states #{states.collect{|s| s.name}.inspect}"
        cp.destroy_aus(states); 
      end
    end
  end 
  
  desc "destroy_empty collections"
  task :destroy_empty_collections => :environment do |t|
    if (start_task(t, {'ACRONYM' => nil, 'PLUGIN' => nil})) then 
      cp = content_provider_get(@opts); 
      if (cp) then 
        puts "destroy empty collections"
        cp.collections.each { |c| 
          if (c.empty?) then 
            puts "destroy #{c.inspect} "; 
            c.destroy
          end
        } 
      end
    end
  end 
  
  desc "create content provider with given name, plugin_prefix, and icon"; 
  task :create  => :environment do |t|
    if (start_task(t, {'NAME' => nil, 
                       'ACRONYM' => nil, 
                       'PLUGIN' => nil, 
                       'ICON_URL' => "http://metaarchive.org/favicon.ico"})) then 
      cp = nil; 
      name = @opts['NAME'];
      acro = @opts['ACRONYM'];
      prefix = @opts['PLUGIN'] 
      icon_url = @opts['ICON_URL']
      
      if (name == nil || prefix == nil || icon_url == nil || acro == nil) then 
        $stderr.puts "Must give NAME, PLUGIN prefix, and a ICON file or ICON_URL name"
        exit 1; 
      end 
      cp = ContentProvider.new(:name => name, 
                                :acronym => acro, 
                                :plugin_prefix => prefix,
                                :icon_url => icon_url); 
      cp.save!
    end
  end
  
  desc "create plugin for content_provider from plugin xml template"; 
  task :create_plugin  => :environment do |t|
    if (start_task(t, {'CP' => nil, 
                       'ACRONYM' => nil, 
                       'PLUGIN_NAME' => nil, 
                       'PLUGIN_FILE' => nil})) then 
      name = @opts['PLUGIN_NAME'];
      plugin_file = @opts['PLUGIN_FILE'] 
      if (plugin_file == nil || @opts['CP'] == nil) then 
        $stderr.puts "Must give CP, and PLUGIN_FILE parameter"
        exit 1; 
      end 
      cp = ContentProvider.find_by_acronym(@opts['CP']);
      if (cp.nil?) then 
        $stderr.puts "Can't find content_priovider '#{@opts['CP']}'"
        exit 1; 
      end
      path, xml = LockssPlugin.get_xml_from_file(plugin_file);
      if (name.nil?) then 
        name = "#{cp.plugin_prefix}.#{path.last}";
      end
      p = LockssPlugin.ingest_plugin(name, cp, xml);      
    end
  end
  
  desc "create plugin for all content_provider from plugin xml template"; 
  task :create_plugins  => :environment do |t|
    if (start_task(t, {'PLUGIN_FILE' => nil})) then 
      plugin_file = @opts['PLUGIN_FILE'] 
      if (plugin_file == nil) then 
        $stderr.puts "Must give PLUGIN_FILE parameter"
        exit 1; 
      end 
      path, xml = LockssPlugin.get_xml_from_file(@opts["PLUGIN_FILE"]);
      
      for cp in ContentProvider.find(:all) do 
        name = "#{cp.plugin_prefix}.#{path.last}"; 
        p = LockssPlugin.ingest_plugin(name, cp, xml);      
      end  
    end
  end
  
  private
  
  def do_cp_on_offline_task(what, t) 
    if (start_task(t, {'ACRONYM' => nil, 'PLUGIN' => nil})) then 
      c = content_provider_get(@opts)
      if (c != nil) then 
        offline = (what == :offline)
        begin 
          ArchivalUnit.transaction do
            c.offline_aus!(offline)
          end
          puts "Set all archival units to offline = #{offline}" ;       
        rescue  Exception => e; 
          $stderr.puts e.message; 
          $stderr.puts "Returning  all archival units in all collections to orginal offline state"; 
        end
      end 
    end
  end
  
  
  def content_provider_get(opts) 
    name = opts['ACRONYM'];
    prefix = opts['PLUGIN']
    if (name != nil) then 
      cp = ContentProvider.find_by_acronym(name)
      if (prefix!= nil && cp.plugin_prefix != prefix ) then 
        $stderr.puts "ContentProvider #{name}'s plugin_prefix is not #{prefix}"
        cp =  nil; 
      end
    elsif (prefix != nil) then 
      cp = ContentProvider.find_by_plugin_prefix(prefix)
    end
    if (cp.nil?) then 
      $stderr.puts "Must give valid ContentProvider acronym or plugin prefix";  
    end
    return cp; 
  end
end
