class LockssAu
  require 'cgi'; 
  
  attr_reader :lockss_au_id;
  attr_reader :plugin_name; 
  attr_reader :base_url; 
  attr_reader :extra_params; 
  attr_accessor :saved; 
  
  public
  
  # create with given lockss archival unit id 
  def initialize(auid)
    @saved = false;
    @lockss_au_id = auid; 
    begin 
      params = auid.split(/&/);
      @plugin_name = params[0].gsub(/\|/, '.');
      @extra_params = {}; 
      for i  in 1 .. (params.length-1) do 
        p = CGI.unescape(params[i]); 
        pp, vv = p.split(/~/)
        @extra_params[pp] = vv;
      end
      @base_url = @extra_params.delete('base_url')
      @base_url = CGI.unescape(@base_url.sub(/^base_url~/, '')) if @base_url;
    rescue
      puts "Malformed lockss au id '#{auid}'"
    end
  end

  def  valid? 
    return !archival_unit().nil? ; 
  end
  
  # plugin derived from lockss archival unit _id
  # nil if no matching plugin exists 
  def plugin 
    if (!defined? @plugin) then 
      @plugin = Plugin.find_by_name(@plugin_name);  
    end 
    return @plugin; 
  end 
  
  # plugin_id derived from lockss archival unit id 
  # nil if no matching archival unit exists 
  def plugin_id
    plugin
    return @plugin.nil? ? nil : @plugin.id; 
  end 
  
  # archival unit derived from lockss archival unit id   
  #
  # nil if no matching archival unit exists 
  def archival_unit 
    if (!defined? @archival_unit) then 
      @archival_unit = ArchivalUnit.find_by_lockss_au_id(@lockss_au_id) ||  
                       ArchivalUnit.find_by_plugin_base_url_params(plugin, base_url, extra_params)
    end 
    return @archival_unit; 
  end 
  
  # archival unit id  derived from lockss archival unit id
  #
  # nil if no matching archival unit exists 
  def archival_unit_id 
    archival_unit;
    return @archival_unit.nil? ? nil : @archival_unit.id; 
  end 
  
  
  # find archival unit corresponding to given lockss au id and 
  # attach the lockss_au to the archival unit 
  def attach_to_archival_unit
    if (valid?) then       
      @archival_unit.lockss_au_id = @lockss_au_id ;
      @saved = @archival_unit.save
    end
  end
  
  # attach lockss auids from lid parameter array to archival units 
  def self.attach_to_archival_units(lids) 
    for lid in lids do 
      lid.attach_to_archival_unit 
    end
  end
  
end 
