class LockssTitleDb 
  
  def initialize(file, nprop_level) 
    @file = file; 
    if (!file.match('.xml$')) then 
      raise  "FILE must be xml"
    end
    file = File.new(file)
    if (!file) then 
      raise "Can't open #{file}"; 
    end
    @doc = REXML::Document.new(file)
    if (!@doc) then 
      raise "Can't parse #{file}"; 
    end 
  end 
  
  # reads xml info given in file and creates collections/archival_units for given archive 
  # * creates corresponding collection with given base_url and plugin if creat_coll 
  # * creates corresponding archival_unit  with given additional parameters for collection if creat_aus and collection can be found/created 
  # * sets au_state of newly created archival_units acccording ro au_state patemeter 
  # * leaves au_state of existing archival_units as is 
  def self.create_from_file(arch, file, do_colls, do_aus, au_state, nprop_level)
    ltdb = LockssTitleDb.new(file, nprop_level); 
    ltdb.apply_elems(nprop_level) do |elem|  
      ltdb.create_au(elem, arch, do_colls, do_aus, au_state);  
    end
  end 
  
  # sets au_state of archival_units defined in file to the given state 
  def self.set_au_state_from_file(file, au_state, nprop_level)
    ltdb = LockssTitleDb.new(file, nprop_level); 
    ltdb.apply_elems(nprop_level) do |elem|  
      ltdb.set_au_state(elem, au_state); 
    end
  end
  
  def apply_elems(nprop_level)
    pattern = "lockss-config"
     (1 .. nprop_level).each { |i| pattern = pattern << "/property" }
    @elements = @doc.elements.each(pattern) do |e| 
      n= e.attribute('name')
      v= n.nil? ? nil : e.attribute('name').value 
      if (!v.nil? && v.match(/title$/)) then 
        title = e; 
        title.elements.each('property') do |au| 
          begin 
            yield(au)  
          rescue 
            puts "ERROR: " + $!
          end
        end 
      elsif (!v.nil?) then 
        puts "Skipping #{n}"
      end
    end
  end 
  
  def create_au(au, arch, create_coll, create_aus, au_state)
    get_au_params(au); 
    c = get_collection(au, arch, create_coll); 
    @params.delete('base_url');
    if (create_aus) then
      au = nil; 
      
      au = ArchivalUnit.new(:collection => c, :param_values => @params, :au_state => au_state)     
      if (au.save) then 
        puts "CREATE: #{au.param_values} in collection '#{c.title}'"; 
      else
        msg = "";
        au.errors.each_full { |e| msg += "\n" + "BECAUSE: #{e}"; } 
        raise "could not create au #{@params.inspect} " +  
                   "in collection '#{c.title}' (#{c.plugin.name}, #{c.base_url})" + msg; 
      end 
    end
    return true; 
  end 
  
  def set_au_state(au, au_state)
    get_au_params(au); 
    aus =  ArchivalUnit.find(:all, 
                            :conditions => { :param_values => ArchivalUnit.hashToParamString(@params) } ); 
    if (aus.empty?) then 
      raise "could not find au with #{@params.inspect}"; 
    end
    if (aus.length > 1) then 
       raise "SHOULD NEVER HAPPEN: there were more than 1 aus with #{@params.inspect} ";
    end
    aus[0].au_state = au_state; 
    aus[0].save(false); 
  end
  
  private
  def get_collection(au, arch, create_coll) 
    c = Collection.find(:first, :conditions => { :title => @coll_name, 
      :archive_id => arch.id, 
      :plugin_id => @plugin.id, 
      :base_url => @params['base_url'] });
    puts c;  
    if (c.nil? && !create_coll) then 
      raise "No such collection '#{@coll_name}' with '#{@plugin_name}', '#{@params['base_url']}'" 
    end 
    
    if (!c.nil?) then 
      puts "\nEXISTS: Collection '#{@coll_name}' with #{@plugin_name}, #{@params['base_url']}"   if (create_coll)   
    elsif (create_coll) then 
      c = Collection.new(:title => @coll_name, 
                         :archive => arch, 
                         :plugin => @plugin, 
                         :base_url => @params['base_url'] )
      if (c.save) then 
        puts "\nCREATE collection #{arch.title}.\'#{@coll_name}\'"
      end
    end
    if (!@coll_descr.empty?) then     
      c.description =@coll_descr; 
    end 
    if (!c.save) then 
        msg = ""; 
        c.errors.each_full { |e| msg +=  "\n" + "BECAUSE: #{e}" } 
        raise "could not create coll '#{@coll_name}' " + 
                  "for \t#{@plugin_name}\t#{@params['base_url']}" + msg;      
    end 
    return c; 
  end
  
  def get_au_params(au) 
    @params = {}; 
    @plugin_name = ""; 
    @coll_name = ""; 
    @coll_descr = ""; 
    @plugin = nil; 
    
    au.elements.each('property') do |elem| 
      attr = elem.attribute('name').value()
      if attr == 'journalTitle' then
        @coll_name =  elem.attribute('value').value
      elsif attr == 'journalDescription' then
        @coll_descr =  elem.attribute('value').value
      elsif attr == 'plugin' then
        @plugin_name = elem.attribute('value').value
      elsif attr.index('param') == 0 then
        param_key = ""; 
        param_value = ""; 
        elem.elements.each('property') do |param|  
          param_attr = param.attribute('name').value()
          if param_attr == 'key' then
            param_key =  param.attribute('value').value
          elsif param_attr == 'value' then
            param_value =  param.attribute('value').value
          end
        end
        @params[param_key] = param_value; 
      end 
    end 
    
    @plugin = Plugin.find_by_name(@plugin_name); 
    if (@plugin.nil?) then 
      raise "unknown plugin \'#{@plugin_name}\' used for collection '#{@coll_name}'"; 
    end 
    
  end
  
end 
