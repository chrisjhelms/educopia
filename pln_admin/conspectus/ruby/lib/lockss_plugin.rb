# utilities to read Plugin xml from file system and creating plugins 
# that attach themselves to content_provider with longets matching plugin_prefix 
#
# plugin parameters are pulled out of xml files if plugin is stored in latest format 
#
# TODO: read recrawl_interval, plugin identifier, plugin notes 
class LockssPlugin 
  
  # read all plugin from  within given directory  
  # trace problem encountered 
  # TOD fix chop 
  def self.find_and_create(file_opt, chop) 
    exclude_pattern = "#{File::SEPARATOR}\\."; 
    if (File.directory?(file_opt) || File.symlink?(file_opt)) then 
      Find.find(file_opt) do |path|
        if  path.match(exclude_pattern) then 
          Find.prune; 
        end 
        if (!File.directory?(path) && path.match('.xml$')) then 
          LockssPlugin.create_from_file(path, chop)
        end
      end
    else 
      LockssPlugin.create_from_file(file_opt, chop)
    end
  end    
  
  # get xml from file 
  def self.get_xml_from_file(file) 
    name = ""; 
    if (file == "") then
      raise"must give FILE parameter"
    end 
    name = file.match('(^.*).xml')
    if (!name) then 
      raise  "#{file} does not end in .xml"; 
    end   
    xml = "EMPTY"; 
    begin 
      xml = File.read(file); 
    rescue 
      raise  "Can't read #{file}";
    end
    path = name[1].split(File::SEPARATOR)
    return [path, xml]; 
  end
  
  # read plugin from file 
  # return nil if encountering error like non existant/unreadable file 
  def self.create_from_file(fname, chopdir) 
    begin  
      path, xml = get_xml_from_file(fname); 
      path = path.slice(chopdir, path.length) 
      if (path.nil? || path.length < 3) then 
        raise "file parameter must contain at least two directory entries beyond the first CHOPDIR (#{chopdir}) entries"; 
      end
      name = path.delete_at(-1); 
      
      cp = nil;
      path.length.downto(1) do |i| 
        plugin_prefix =   path.slice(0,i).join("."); 
        cp = ContentProvider.find_by_plugin_prefix(plugin_prefix)
        break if cp
        i = i-1; 
      end
      raise "Could not find content provider for #{path.join('/')}" if cp.nil?
      
      name = "#{path.join(".")}.#{name}";
      p = ingest_plugin(name, cp, xml); 
      return p;
    rescue 
      puts $stderr.puts $! 
      return nil;
    end 
  end
  
  private
  # parse file and create plugin 
  # raise exception on parsing errors 
  def self.ingest_plugin(name, cp, xml) 
    p = Plugin.find_by_name(name, :conditions => { :content_provider_id => cp.id});
    if (p.nil?) then
      begin 
        p = Plugin.get(name, cp);
        puts "CREATE plugin #{name} for #{cp.name}";
        doc = REXML::Document.new(xml)
        if (!doc) then 
          raise "ERROR: Can't parse #{file}"; 
        end
        param_hash = {}; 
        doc.elements.each('map/entry/list/org.lockss.daemon.ConfigParamDescr') { |e|
          begin 
            key = e.elements['key'].get_text().value(); 
            type = e.elements['type'].get_text().value(); 
            descr = e.elements['description']; 
            if (descr.nil?) then 
              descr = ""; 
            else 
              txt = descr.get_text(); 
              descr = txt.nil? ? "" : txt.value(); 
            end
            param_hash[key] = { :kind => PluginParam.toKind(type), :descr => descr } ;     
          end 
        }
        if  (param_hash.inspect.empty?) then 
          raise "XML ERROR: plugin #{name} for #{cp.name} has outdated format"
        elsif (!p.merge_params(param_hash)) then 
          raise "ERROR: Parameter creation failed for plugin #{name} for #{cp.name}"
        end
        
      rescue Exception => e 
        p.destroy; 
        raise e 
      end
      
    else
      raise "EXISTS plugin #{name} for #{cp.name}";
    end
    return p; 
  end
  
end
