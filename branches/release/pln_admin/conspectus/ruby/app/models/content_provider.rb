require "uri"

# ContentProviders have a name, plugin_prefix, and a an icon file 
# * name and plugin prefiix  must be unique across the application.
# * icon files must reside in ./public.images./content_providers 
#
# ContentProviders have
# * many plugins: with names starting with plugin_prefix
# * many collections: which use the providers plugins for their definition
# * can not change their plugin_prefix after plugins were created for them 
# * can not be destroyed after plugins were created for them; this means no destruction if replicated content potentially exists in the network) 
class ContentProvider < ActiveRecord::Base
  include ActiveRecordExtension 
  include ActiveRecord::Calculations
  
  validates_presence_of :name, :plugin_prefix, :icon_url, :acronym
  validates_format_of :plugin_prefix, :with => /\A[a-z0-9][a-z0-9.]*\Z/i
  validates_uniqueness_of :name, :plugin_prefix, :acronym
  
  #has_many :plugins, :order => 'name ASC';
  has_many :users, :order => 'last_name ASC'
  has_many :content_provider_status_items; 
  
  # return reference to content ptoviders placeholder plugin 
  def placeholder_plugin
    return Plugin.find(placeholder_plugin_id)
  end
  
  # return number of true plugins (not counting placeholder)  
  def plugin_count
    return plugins.length - 1; 
  end
  
  # create placeholder plugin on first save of content_provider 
  def after_save() 
    if (self.placeholder_plugin_id == nil) then 
      p = Plugin.new(:content_provider => self, 
                      :name => "#{self.plugin_prefix}.NONE")
      p.save!
      self.placeholder_plugin_id = p.id;
      self.save!
    end 
  end
  
  # all collections that use plugins from this content provider
  # state parameter: include all, retired, or active collections in listing (all is default)
  def collections(ordered = false, state = 'all')
    opts = ordered ? {:order => :title } : {}; \
    conds = { :plugins => { :content_provider_id => self.id } }
    if (state == 'active') then 
      conds = conds.merge( :collections =>  { :retired => false } )
    elsif (state == 'retired') then 
      conds = conds.merge( :collections =>  { :retired => true } )
    end
    Collection.find(:all, 
    opts.merge(:joins => :plugin, 
                       :conditions => conds))
  end
  
  # all plugins in this archive 
  # state parameter: include all, retired, or active plugins in listing 
  def plugins(ordered = true, state = 'all')
    opts = ordered ? {:order => :name } : {}; \
    conds = { :content_provider_id => id }
    if (state == 'active') then 
      conds = conds.merge( :retired => false  )
    elsif (state == 'retired') then 
      conds = conds.merge( :retired => true )
    end
    Plugin.find(:all, opts.merge( :conditions => conds))
  end 
  
  # all collections, including retired 
  def collections_count
    Collection.count(:all, :joins => :plugin, :conditions => { :plugins => { :content_provider_id => self.id } })
  end 
  
  # union of archival_units_filter_by_states over all collections 
  def archival_units_filter_by_states(states) 
    return Collection.archival_units_filter_by_states(collections, states);  
  end 
  
  # removes extra blanks from name
  def name=(str) 
    self[:name] = compact_string(str); 
  end
  
  # removes extra blanks from aconym
  def acronym=(str) 
    self[:acronym] = compact_string(str); 
  end
  
  # plugin_prefix may not change if plugins exist that refer to this content provider
  def plugin_prefix=(str) 
    self[:plugin_prefix]  = compact_string(str)
  end
  
  # removes extra blanks from icon_url     
  def icon_url=(str)       
    self[:icon_url] = compact_string(str);       
  end 
  
  # set all colections to offline!
  def offline_aus!(off)  
    collections.each { |col| 
      col.offline_aus!(off); 
    } 
  end
  
  # assign new state to archival units in a given old state  
  # raise exception if any archival unit failes to update its state 
  def change_state_aus!(old, new, assume_super_user = false)  
    aus = archival_units_filter_by_states([old]); 
    aus.each do |au|
      au.au_state = new; 
      au.assume_super_user = assume_super_user
      au.save!
    end
  end
  
  # destroy all aus in given states 
  # raise exception and rollback to original state uupon failure to delete aus
  def destroy_aus(states) 
    ArchivalUnit.transaction do 
      aus = archival_units_filter_by_states(states); 
      aus.each do |au|
        au.destroy
      end 
    end
  end
  
  # can this content_provider be destroyed ? 
  def may_destroy?
    return plugins.length == 1;
  end
  
  #  can't destroy if plugins exist that refer to this content provider
  def destroy 
    raise "#{self.class.name} #{name} (#{self.plugin_prefix}) has plugins; can't destroy" if !may_destroy?
    placeholder_plugin.destroy
    ContentProvider.delete(self.id)
  end
  
  # update preservation status information
  def update_status() 
    ContentProviderStatusItem.update(self)
  end
  
  # check that plugin_prefix is not empty, icon_url has proper location and exists
  def validate
    #puts "> #{self.class.name}.validate"
    dbvals = self; 
    if (!new_record?) then 
      dbvals = self.class.find(self.id)
    end 
    
    if (errors.empty?) then
      # make sure plugin_prefix has at least one part
      if (! plugin_prefix.match(/^[a-zA-Z0-9.\-]+$/)) then
        errors.add_to_base("Plugin Prefix may contain only a-z, A-Z, 0-9, and -")
      end
      
      if (!new_record?) then  
        # refuse if plugin_prefix changed versus plugin stored in database  if self has plugins 
        if (plugin_prefix != dbvals.plugin_prefix) then  
          if (plugins.length > 1) then    
            self.errors.add('plugin_prefix',  "#{self.class.name} has plugins; can't change") 
          else
            placeholder_plugin.destroy
            self.placeholder_plugin_id = nil;
          end
        end
      end 
      
      icon_url_dir = "/images/content_providers";      
      if (new_record? || icon_url != dbvals.icon_url) then 
        begin
          first = "" << icon_url[0];
          if ("/" != first) then
            # if it does not start file "/" assume its a url 
            data = NetData.new(icon_url, "GET"); 
            if (200 != data.status) then 
              raise  "Could not fetch #{icon_url}"; 
            end
            url_file = "#{icon_url_dir}/#{acronym}.ico";
            begin 
              open("./public#{url_file}", 'wb' ) { |file|
                file.write(data.body)
              }
              self.icon_url = url_file 
            rescue 
              raise "could not write file ./public#{url_file}" 
            end
          end
          if (!self.icon_url.match(Regexp.new("^#{icon_url_dir}\/")))  then 
            raise "icon_url must start with '#{icon_url_dir}'  (#{icon_url})"   
          end 
          if (!self.icon_url.match(Regexp.new("[iI][cC][oO]$")))  then 
            raise "icon_url must must be an ico file"   
          end 
        rescue Exception => e
          errors.add_to_base(e.message)
         end 
      end
      if (!File.exists?("./public#{icon_url}")) then
        errors.add_to_base("./public#{icon_url} does not exist")     
      end
    end
    #puts "< #{self.class.name}.validate";   
    return errors.empty?;
  end
  
  def to_xml(options={})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])  
    plugs = plugins;
    if (!plugs.empty?) then 
      xml.instruct! unless options.delete(:skip_instruct)   
      xml.property(:name =>  acronym) do 
        xml.property(:name => 'name', :value => name)
        xml.property(:name => 'class', :value => "xpath")
        xml.property(:name => 'xpath', :value => "[starts-with(pluginName, '#{self.plugin_prefix}')]")
      end
    else 
      return nil;
    end
  end
  
  def as_json(opts = {})
     extra = {}; 
     extra['collections'] = 
            collections.collect{ |c| c.id };
     super.as_json(opts ).merge( extra )
  end
   
  #  create/update content providers from "config/<site>/content_providers.yml" 
  def self.update(site)
    puts "--- #{self.name}.update"; 
    list = YAML.load_file("config/data/#{site}/content_providers.yml")
    list.each { |k,h| 
      begin  
        cp = ContentProvider.find_by_acronym(h['acronym']); 
        if (cp.nil?) then 
          cp = ContentProvider.new(h); 
        else 
          cp.update_attributes(h);   
        end
        if (cp.icon_url.nil?) then 
          cp.icon_url = "/images/content_providers/#{cp.acronym}.ico"; 
        end
        cp.save!
        puts "> #{cp.name} #{cp.acronym}";
      rescue
        puts "Could not create/update ContentProvider #{k}"
        $stderr.puts $!; 
      end 
    } 
  end
end
