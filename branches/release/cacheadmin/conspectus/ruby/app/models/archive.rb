# Archives have a unique name and a required description. They contain Collections  
class Archive < ActiveRecord::Base
  
  include ActiveRecordExtension 
  include ActiveRecord::Calculations
    
  validates_uniqueness_of :title
  validates_presence_of :title, :description
  has_many :collections, :order => 'title ASC', :dependent => :destroy;
  has_many :archival_units, :through => :collections; 
  #has_many :plugins, :through => :collections, :order => 'name ASC'; 
  has_many :archive_status_items;
  
  # removes extra blanks from title
  def title=(str) 
    self[:title] = compact_string(str);
  end
  
  # removes extra blanks from description
  def description=(str) 
    self[:description] = compact_string(str);
  end
  
 
  # returns the number of collections, includinf retired ones
  def collections_count
    Collection.count(:all, :conditions => { :archive_id => self.id } )
  end 
  
  def may_destroy?
    return (not new_record?) && collections_count == 0;
  end
  
  # all collections in this archive 
  # state parameter: include all, retired, or active collections in listing 
  def collections(ordered = false, state = 'all')
    opts = ordered ? {:order => :title } : {}; \
    conds = { :archive_id => id }
    if (state == 'active') then 
      conds = conds.merge( :retired => false  )
    elsif (state == 'retired') then 
      conds = conds.merge( :retired => true )
    end
    Collection.find(:all, opts.merge( :conditions => conds))
  end 
  
   
  # all plugins in this archive 
  # state parameter: include all, retired, or active plugins in listing 
  def plugins(ordered = true, state = 'all')
    opts = ordered ? {:order => :name } : {}; \
    conds = { :collections => { :archive_id => id } }
    if (state == 'active') then 
      conds = conds.merge( :plugins => {:retired => false  } )
    elsif (state == 'retired') then 
      conds = conds.merge( :plugins => {:retired => true  } )
    end
    Plugin.find(:all, opts.merge( :joins =>:collections, :conditions => conds))
  end 

  # return all collections with archival units in given states 
  def collections_filter_by_states(states) 
    collections.select { |c| c.archival_units_filter_by_states_count(states) != 0 }
  end
  
  # union of archival_units_filter_by_states over all collections 
  def archival_units_filter_by_states(states) 
    return Collection.archival_units_filter_by_states(collections, states);  
  end 
  
  # * assigns metadata editor url for given action, where the action may be :create, :update, :show 
  # * removes extra blanks from url_pattern
  # * the url_pattern may contain strings <BASE_URL>, <PLUGIN>, and <TITLE> 
  #  which are replaced when generating a link for a particular collection 
  def metadata_url_pattern(action, str) 
    url = compact_string(str);
    if (action == :create) then 
        self[:create_url_pattern] = url;
    elsif (action == :update) then 
         self[:update_url_pattern] = url;
    elsif (action == :show) then
         self[:show_url_pattern] = url;
    else 
      raise "unknow action #{action}"; 
    end 
  end
    
  # returns the metadata editor url for the given action 
  # for allowed actions see metadata_url_pattern
  def metadata_url(action)
    if (action == :create) then 
        return self.create_url_pattern
    elsif (action == :update) then 
         return self.update_url_pattern
    elsif  (action == :show) then
        return self.show_url_pattern
    else 
      raise "unknow action #{action}"; 
    end 
    return nil; 
  end
  
  # raise exception if archive contains collections 
  def destroy 
    raise "Can't destroy; #{title} archive has collections" if not may_destroy?
    Archive.delete(id)
  end
  
  # update preservation status information
  def update_status() 
    ArchiveStatusItem.update(self)
  end
  
  # generate xml format suitable for LOCKSS title database
  def to_xml(options={})
       options[:indent] ||= 2
       xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
       states = options[:states]; 
       xml.instruct! unless options.delete(:skip_instruct)     
       xml.property(:name =>  "title") do 
            archival_units_filter_by_states(states).each do  |au| 
              au.to_xml(options.merge(:builder => xml, :skip_instruct => true))
           end
       end 
  end

  def as_json(opts = {})
       extra = {}; 
       extra['collections'] = 
              collections.collect{ |c| c.id };
       super.as_json(opts ).merge( extra )
  end
    
  # generate xml format for plugins() 
  def plugins_xml(options={})
       options[:indent] ||= 2
       xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
       ps = plugins();
       xml.instruct! unless options.delete(:skip_instruct)     
       xml.property(:name =>  "plugins") do 
            ps.each do  |p| 
              p.to_xml(options.merge(:builder => xml, :skip_instruct => true))
           end
       end 
  end
  
  # make sure 
  # * that :create url pattern is set whenever update/show urls are defined 
  def validate 
    # puts "validate #{self.inspect}"
    if (errors.empty?) then
      # either all url patterns are set or all are empty 
      self.update_url_pattern = "" if self.update_url_pattern.nil? 
      self.show_url_pattern = "" if self.show_url_pattern.nil? 
      self.create_url_pattern = "" if self.create_url_pattern.nil? 
      if (update_url_pattern.empty? || show_url_pattern.empty? || create_url_pattern.empty?) then 
        errors.add_to_base("must define all or no url patterns") unless 
                create_url_pattern.empty?  &&
                show_url_pattern.empty? &&
                update_url_pattern.empty?; 
      elsif  (!update_url_pattern.empty? || !show_url_pattern.empty? || !create_url_pattern.empty?) then 
          errors.add_to_base("must define all or no url patterns") unless 
                !create_url_pattern.empty?  &&
                !show_url_pattern.empty? &&
                !update_url_pattern.empty?; 
      end
    end
    return errors.empty?
  end
  
  def self.update(site) 
    puts "--- #{self.name}.update"; 
    list = YAML.load_file("config/data/#{site}/archives.yml")
    list.each { |k,h| begin  
         a = Archive.find_by_title(h['title'])
         if (a.nil?) then 
           a = Archive.new(h); 
         else 
           a.update_attributes(h);   
         end
         a.save!
         puts "> #{a.title}";
       rescue
         puts "Could not create/update Archive #{k}"
         puts $!; 
       end 
    } 
  end 
end
