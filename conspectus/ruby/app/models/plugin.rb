# Plugins have a name and refer to a ContentProvider
# Their name must begin with the content_provider's plugin_prefix.
# Plugins are created/retrieved with Plugin.get
class Plugin < ActiveRecord::Base
  include ActiveRecordExtension

  belongs_to :content_provider
  has_many :collections, :order => 'title ASC'
  has_many :plugin_params, :order => 'name ASC', :dependent => :destroy
  validates_presence_of :content_provider
  validates_uniqueness_of :name

  # retrieve or create and save plugin with given name and content_provider
  # return created unsaved plugin if there are errors 
  def self.create(name, contentProv)
    name = ActiveRecordExtension.compact_string(name)
    p = find_by_name(name)
    if (!p.nil?) then
        return nil if  p.content_provider != contentProv
        return p
    end
    p = Plugin.new(:name => name, :content_provider => contentProv);
    if (!p.save) then
      return p;
    end
    pp =  PluginParam.new(:name => 'base_url',
                          :kind => 'url',
                          :descr => 'Usually of the form http://.. or https://...',
                          :plugin => p)
    pp.save
    return p;
  end

  # retrieve or create and save plugin with given name and content_provider
  # return nil if save fails 
  def self.get(name, contentProv)
    p = create(name, contentProv)
    if (p.new_record?) then 
        return nil;
    end
    return p; 
  end


  before_destroy { |plugin|
    if !plugin.collections.empty? then
        puts raise "Plugin has collections, can't destroy"
    end
  }

  # * removes extra blanks from base_url
  # * raises exception if this is not a new record
  def name=(str)
    if (new_record?) then
      write_attribute(:name, str);
    elsif has_aus() then
      raise "can't change name of saved Plugin #{name}" if self.name != str
    end
  end


  # raises exception if this is not a new record
  def content_provider=(cp)
    raise "content_provider must not be nil" if cp.nil?
    if (new_record?) then
      write_attribute(:content_provider_id, cp.id);
    else
      raise "can't change content provider of saved Plugin #{name}" if self.content_provider != cp
    end
  end

  def placeholder?
    content_provider.placeholder_plugin == self
  end

  def file_name()
    return "" if placeholder?
    return name.gsub("\.", "/") + ".xml";
  end
  
  def display_name()
    return "UNDEFINED" if placeholder?
    return name;
  end

  # returns the paramter with the given name or nil
  def param(name)
    return PluginParam.find(:first, :conditions => { :plugin_id => self.id, :name => name} );
  end

  def may_edit
    return !has_aus() && !placeholder?;
  end

  def may_delete
    return collections.count == 0;
  end

  def params_count 
    return plugin_params.count;
  end
  
  # returns whether plugin has collections with archival_units
  def has_aus()
    for c in collections do
      if (0 < c.archival_units.length) then
        return true
      end
    end
    return false;
  end

  # returns number of parameters 
  def params_count()
    return plugin_params.count; ;
  end

  # return all archival_units that use this plugin (through their collection)
  def archival_units(base_url = nil)
    aus = [];
    for c in collections do
      if (base_url.nil? || c.base_url == base_url) then
         aus += (c.archival_units)
      end
    end
    return aus;
  end

  # union of archival_units_filter_by_states over all collections 
  def archival_units_filter_by_states(states) 
    return Collection.archival_units_filter_by_states(collections, states);  
  end 
  
  # returns set of parameter names 
  # if mode is set to :no_base_url it excludes the base_url parameter
  def param_names(mode = :base_url)
    p = plugin_params.collect{ |pp| pp.name }
    if (mode != :base_url) then 
       p.delete("base_url"); 
   end
   return p;
  end

  # merges the parameters from the hash into the existing parameters and saves
  # returns or of save results
  def merge_params(hash)
    ret = true;
    hash.keys.each  { |pname|
      pp = param(pname)
      if (!pp.nil?) then
        pp[:kind] = hash[pname][:kind]
        pp[:descr] = hash[pname][:descr]
      else
        pp =  PluginParam.new(:name => pname,
                          :kind => hash[pname][:kind],
                          :descr => hash[pname][:descr],
                          :plugin => self)
      end
      ret = pp.save || ret;
    }
    return ret
  end

  # * returns [] or list of mismatching param values
  def param_values_match?(values)
    errs = [];
    values.keys.each { |pname|
       pp = param(pname);
       if (!pp.nil?) then
         # TODO check whether value converts properly to param kind
       else
         errs << "plugin does not have a '#{pname}' parameter"
       end
    }
    undefs = plugin_params.collect { |pp| pp.name } - values.keys
    undefs.each { |u|
         errs << "no value for plugin's '#{u}' parameter"
    }
    return errs
  end


  # returns nil if Global has no url setting for test plugins
  # or derive url from plugin name and Glogal's test_plugin_url '
  # PARAM mode should be either "test" or "production"
  def xml_url(mode)
    return "" if placeholder?
    url = nil;
    url = Global.get(mode);
    if (url.nil?) then
        return "";
    end
    url = url.gsub(/<PLUGIN_FILE>/, file_name);
    return url;
  end

  def as_json(opts = {})
      extra = {}; 
      plugin_modes = Global.plugin_urls.collect { |p| p.name }; 
      plugin_modes.collect { |n|  extra[n] = xml_url(n) }; 
      extra['param'] = param_names; 
      extra['collections'] = 
           collections.collect{ |c| c.id };
      super.as_json(opts ).merge( extra )
  end
    
   def toStr
     str = "id:#{id} '#{name} (#{content_provider.name})";
     return str;
   end


  protected
  # makes sure name starts with content providers plugin_prefix followed by a dot (.)
  # make sure content provider is saved record
  # do not retire if there are archival units that are not retired 
  def validate
   if (errors.empty?) then
     if (!name.match(/^[a-zA-Z0-9.]*$/))
       errors.add_to_base("Name may contain only a-z, A-Z, 0-9, and . (dot) characters\`")
     end
     if (!name.match(/^#{content_provider.plugin_prefix}\./))
       errors.add_to_base("Name must start with \'#{content_provider.plugin_prefix}.\`")
     end
     if (name.match(/\.$/)) then 
       errors.add_to_base("Name may not end with a . (dot)")
     end
     if (content_provider.new_record?) then
          errors.add_to_base("Can't attach to unsaved content provider #{cp.name}" )
     end
     if (errors.empty? && retired) then 
         archival_units.each do |au| 
           if (!au.retired?) then 
             errors.add_to_base("Plugin has archival unit that is not yet retired"); 
             break;
           end
         end
     end
   end
  end
end
