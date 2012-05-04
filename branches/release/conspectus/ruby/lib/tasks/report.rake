namespace :report do
  require 'csv'
  require 'rexml/document'  
  require 'tasks/rake_option'
  require 'tasks/task_helper'
  include Task;
  
  desc "list archival units in given states (separate state names  by ',')"
  task :list_aus  => :environment do |t|
    if (start_task(t, {'STATES' => 'retest,preserved', 'FORMAT' => 'CSV'})) then
      states = get_states( @opts['STATES']); 
      format = @opts['FORMAT']   
      aus = ArchivalUnit.find_by_states(states); 
      if (format == 'CSV') then 
        task_trace t,  ArchivalUnit.to_csv(:au_list => aus); 
      else 
        task_trace t,  ArchivalUnit.to_xml(:au_list => aus); 
      end
    end
  end
  
  desc "list collectins and preservation status info"
  task :list_collection_status  => :environment do |t|
    if (start_task(t, {'CP' => '', 'ARCHIVE' => '', 'FORMAT' => 'CSV'})) then
      ar = task_get_archive('ARCHIVE', @opts); 
      cp = task_get_content_provider('CP', @opts); 
      format = @opts['FORMAT']   
      if (cp.nil? && ar.nil?) then 
        $stderr.puts "Must give either CP or ARCHIVE paameter\n";
      else 
        colls = [];
        if (cp) then
          colls = cp.collections; 
        else
          colls = ar.collections; 
        end
        lines = ""
        fields = [:n_preserved_aus,
                  :avg_size, :avg_disk_usage, :total_size, :total_disk_usage,
                  :min_agreement, :max_agreement,
                  :min_repl, :max_repl]; 
        CSV::Writer.generate(lines) do |csv|
          first = true; 
          for c in colls do 
            if (!c.retired) then
              status = CollectionStatusItem.summary(c); 
              if (first) then 
                first = false; 
                csv << ["id", "title", "CP", "ARCHIVE"] + fields; 
              end
              t = c.title.gsub(/'/,'')
              row = [c.id, "'#{t}'", c.content_provider.acronym, c.archive.title] ;
              csv << (row + fields.collect { |f| status[f] }) 
            end 
          end
        end
        puts  lines; 
      end
    end
  end    
  
  desc "check replication status of archival units in given states (separate state names  by ',')"
  task :check_au_replications  => :environment do |t|
    if (start_task(t, {'STATES' => 'preserved,retest', 
                       'URL' => 'http://localhost:3001/archival_units/status'} )) then
      states = get_states( @opts['STATES']); 
      path = @opts['URL']; 
      ArchivalUnit.find_by_states(states).each{ |au|
        dir = "#{path}?[plugin]=#{au.plugin.name}&[base_url]=#{CGI::escape(au.base_url)}";
        pvalues = au.au_param_values; 
        params = ""; 
        if (!pvalues.empty?) then 
          pvs = []; 
          pvalues.keys.sort.each { |k| 
            v = pvalues[k]; 
            pvs << "#{k}=#{CGI::escape(v)}"
          }
          params = pvs.join('&');
          dir = dir + '&' + params;
        end
        dir = dir + '&format=xml';
        rep = archival_unit_status_info(dir);
        task_trace t,  "#rep: #{rep}\t#{au.plugin.name}\t#{au.base_url}\t#{params}\t#{au.collection.title}\t#{dir}\n";  
      }
    end
  end
  
  
  def get_states(state_name_list)
    states = AuState.getList(state_name_list); 
    if states.empty? then
      raise "No valid states listed in  \'#{state_name_list}\'";
    end
    return states
  end
  
  def archival_unit_status_info(url)
    xml_data = Net::HTTP.get_response(URI.parse(url)).body
    #task_trace t,  xml_data + "\n\n";
    doc = REXML::Document.new(xml_data)
    cnt = 0; 
    doc.elements.each('archival-units/CacheArchivalUnitSet/Elements/CacheArchivalUnit')  do |elem|
      cnt = cnt + 1;
    end
    return cnt;
  end
  
  
end
