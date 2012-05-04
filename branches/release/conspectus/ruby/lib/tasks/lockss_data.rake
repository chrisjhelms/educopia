namespace :lockss_data do
  require 'find'
  
  require 'rexml/document'
  
  require 'tasks/rake_option'
  require 'tasks/task_helper'
  include Task; 
  
  desc "seed with archives, content_providers"
  task :redo  => %w(environment db:drop db:create db:migrate metaarchive:seed lockss:import_plugins lockss:ingest_title_xml) 

  desc "seed with archives, content_providers"
  task :seed  => :environment do |t|
    if (start_task(t, {})) then 
      if (!Archive.new( :title => "Muse", 
                        :description => "LOCKSS Muse Project, archival unit definitions based on /lockss-daemon /test /frameworks /title_db_files /muse_titles.xml").save ) then 
          puts "EXISTS?: could not create Archive LOCKSS"
      end
      if (!Archive.new( :title => "CLOCKSS", 
                        :description => "CLOCKSS Project, archival unit definitions based on /lockss-daemon /test /frameworks /title_db_files /clockss/ *.xml").save ) then 
          puts "EXISTS?: could not create Archive LOCKSS"
      end
      [ [ "lockss-za",  "za" ], 
      [ "lockss-us", "us" ], 
      [ "lockss-uk", "uk" ], 
      [ "lockss-org", "org" ],
      [ "lockss-nz", "nz" ],
      [ "lockss-in", "in" ],
      [ "lockss-gov", "gov" ],
      [ "lockss-edu", "edu" ],
      [ "lockss-de", "de" ],
      ].each { |name, dns|   
        plugin_prefix =  dns.split('.').reverse.join(".")
        c = ContentProvider.new( :name => name, 
                                :plugin_prefix => plugin_prefix,
                                :icon_url => "/images/content_providers/#{dns}.ico" )
        if (!c.save) then 
          puts "EXISTS?: could not create ContentProvider #{name} #{plugin_prefix}"
        else
          puts "CREATE: #{c.inspect}"; 
        end      
      } 
    end
  end
  
end
