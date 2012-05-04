# Collections are identified by a title, or (plugin, base_url) pair. 
# They belong to a content_provider as defined by their plugin's content_provider relationship. 
# Their titles are unique across content_providers as well as across archives 
# The combination of base_url,plugin is unique across all Collections 
#
# Collections may contain many archival_units  
# 

require 'net/http'
require 'rexml/document' 
require "csv"  

class Collection < ActiveRecord::Base
  include ActiveRecordExtension 

  belongs_to :archive; 
  belongs_to :plugin; 
  has_many(:archival_units, 
           :order => 'param_values ASC', 
           :include => :au_state, 
           :dependent => :destroy); 
  has_many(:collection_status_items, 
           :order => :'cache ASC',
           :dependent => :destroy); 
  
  # intentionally not enforcing presence of description 
  validates_presence_of :title, :archive, :base_url, :plugin
  validates_uniqueness_of :title, :scope => :archive_id
  
  # can't destrpy if it has archval_units 
  before_destroy { |coll| 
    if !coll.archival_units.empty? then 
        raise "Collection has archival units, can't destroy" 
    end
  }

  # removes extra blanks from title
  def title=(str) 
    self[:title] = compact_string(str);
  end
  
  # * removes extra blanks from base_url
  def base_url=(str) 
    cstr = compact_string(str)
    if new_record? then
      self[:base_url] = cstr
    else
      if (self[:base_url].casecmp(cstr) == 0) then 
        return;
      end
      if (archival_units_filter_by_states(AuState.irreversibles).empty?) then 
          self[:base_url] = cstr
      else 
        raise "You may not change the base_url; collections has permanent archival units"
      end
    end
  end

  # * destroys previously stored plugin if that plugin has no other collections 
  # * raises exception if given plugin is nil 
  def plugin=(p) 
    raise "must give non nil plugin" if p.nil? 
    op = plugin; 
    self[:plugin_id] = p.id;   
    if (save) then 
      if (op && !op.placeholder? && op.collections.length == 0) then 
        op.destroy
      end
    end
  end
  
  # set all archival units to given offline state 
  # raise exception if any au fails to go offline 
  def offline_aus!(off)  
    archival_units.each do |au| 
      au.offline!(off);
    end
  end

  # retire/unretire all archival unirs in this collection   
  # skip validations if val = false  
  # raise exception if au save fails  
  def retire_aus!(ret, val = true)
    archival_units.each do |au| 
        au.retire!(ret, val) && all; 
    end
  end

  # returns nil or plugins content provider
  def content_provider 
    if (plugin.nil?)
        return nil;
     end
     return plugin.content_provider; 
  end
  
  # return true/false if it contains archival_units (or not) 
  def empty? 
    return archival_units_count == 0; 
  end
  
  # return true/false if contains no aus in states listed by AuState.irreversibles() 
  def editable?
     return archival_units_filter_by_states(AuState.irreversibles()).length == 0
  end
  
  # return true/false if it collection has a plugin  
  def has_plugin? 
    return !plugin.placeholder?
  end
  
  # return true/false if it collection has preservation status information  
  def has_status? 
    return 0 != CollectionStatusItem.count(:all, :conditions => { :collection_id => self.id } )
  end
  
  def archival_units_count
     ArchivalUnit.count(:all, :conditions =>  { :collection_id => self.id } ) 
  end 

  # return true/false if it additional aus may be added 
  def can_add_aus
    return false if !has_plugin? 
    return true if archival_units_count == 0; 
    return true if (plugin.plugin_params.length > 1)
    return false;
  end
  
  # run archive.metadata_url(:create) and  use created id as remote_id 
  def get_remote_metadata
    if (!self.remote_id) then 
      url = archive.metadata_url(:create)
      if (url && url != '') then 
        begin 
          xml_data = Net::HTTP.get_response(URI.parse(url)).body
          doc = REXML::Document.new(xml_data)
          id =  doc.elements['collection/id'].text
          self.remote_id = id; 
          save! 
        rescue
          return nil;
        end
      end 
    end
    return self.remote_id;
  end

  # returns nil if archive has no metadata editor for given action or returns 
  # archive.metadata_url for given action replacing TITLE, BASE_URL, and PLUGIN values in the url pattern 
  def metadata_url(action) 
    url = nil; 
    get_remote_metadata(); 
    if (remote_id) then 
      url = archive.metadata_url(action);
      if (url.nil? || url.empty?) then 
        return nil;
      end 
      url = url.gsub(/<TITLE>/, title);
      url = url.gsub(/<ID>/, "#{remote_id}");
    end
    return url;
  end 

  # returns nil if Global has no url setting for premis
  # or derive url from collection id  and Glogal's premis_url '
  def premis_url()
    url = nil;
    url = Global.premis_url
    if (url.nil?) then
      return nil;
    end
    url = url.gsub(/<COLLECTION_ID>/, "#{self.id}");
    return url;
  end

  # returns nil if Global has no url setting for status
  # or derive url from collection id  and Glogal's premis_url '
  def status_url()
    url = nil;
    url = Global.status_url
    if (url.nil?) then
      return nil;
    end
    url = url.gsub(/<COLLECTION_ID>/, "#{self.id}");
    url = url.gsub(/<CONTENT_PROVIDER_ID>/, "#{self.content_provider.id}");
    return url;
  end

  def update_status()
    CollectionStatusItem.update(self)
  end
  
  # make sure 
  # * base_url starts with http or https 
  # * make sure title is unique across content_provider 
  # * make sure we do not change base_url/plugin if archival units exists 
  def validate 
    # make sure base_url is a url
    if (errors.empty?) then
      # puts "validate #{self.inspect}"
      
      # check for proper URI formatting 
      uri = URI.parse(base_url)
      if (!uri.host ||
          !(uri.scheme == "http" || uri.scheme == "https")) 
        errors.add_to_base("base_url must be a valid url starting with http or https")
      end
      
      # check unique within archive 
      others = Collection.find_filter_by_title(/^#{title}$/i, content_provider.collections)
      others.delete(self); 
      if (!others.empty?) then 
        errors.add_to_base("content_provider #{content_provider.name} already has a collection with the given title")        
      end
      
      # check remote_id greater zero 
      if (remote_id && remote_id < 0) then 
        errors.add_to_base("remote_id must be >= 0"); 
      end 
      
      
      if (!new_record?) then 
        # non editable collections can not change plugin or base_url 
        if (!editable?) then 
          # can't change base_url/plugin anymore 
          # "existing record : check base_url / plugin unchanged" 
          stored = Collection.find(self.id)
          if ((stored.plugin.id != plugin.id) || (stored.base_url != base_url)) then 
            errors.add_to_base("Collection has archival units; can't change plugin #{plugin} #{stored.plugin} or base_url");
          end
        else
          # reset base_url in archivel units 
          archival_units.each { |au| 
            au.reset_signature(base_url); 
            au.save(false)
          }
        end
      end
      
      # retired collections may not haveactive archival units 
      if (retired) then 
         archival_units.each do |au| 
           if (!au.retired?) then 
             errors.add_to_base("Collection has archival unit that is not yet retired"); 
             retired = false;
             break;
           end
         end
      end
    end
    #puts errors.inspect; 
    return errors.empty?
  end

  # return true if title matches the given pattern 
  def self.find_filter_by_title(pattern, list = Collection.find(:all))
    return list.select { |c| c.title.match(pattern) }
  end
  
  # return list of archival_units which have are in one of the given states 
  #
  # if states is nil return all AuStates 
  # if states is empty return [] 
  def archival_units_filter_by_states(states) 
    raise "Use only on saved collections" if new_record?
    if (states.nil? || archival_units.empty?) then 
      return  archival_units
    elsif (!states.empty?) then 
      match = states.collect{ |s| "( `au_state_id` = #{s.id} )" }.join(" OR ")
      return ArchivalUnit.find(:all, 
               :conditions => "`collection_id` = #{self.id} AND ( #{match} )"); 
    end
    return [];
  end
  
  def self.archival_units_filter_by_states(collections, states) 
    return collections.collect { |c| c.archival_units_filter_by_states(states) }.flatten;
   end
  
  # return count of archival_units which have are in one of the given states 
  #
  # if states is nil count all aus; 
  # if states is empty return 0 
  def archival_units_filter_by_states_count(states) 
    raise "Use only on saved collections" if new_record?
    if (states.nil? || archival_units.empty?) then 
      return  archival_units_count
    elsif (!states.empty?) then 
      match = states.collect{ |s| "( `au_state_id` = #{s.id} )" }.join(" OR ")
      return ArchivalUnit.count(:all, 
               :conditions => "`collection_id` = #{self.id} AND ( #{match} )"); 
    end
    return 0;
  end
  
  def self.find_by_plugin_baseurl(plgn, burl) 
    p = Plugin.find_by_name(plgn); 
    if (p.nil?) then
       return []; 
    end 
    col = Collection.find(:all, 
                          :conditions => { :base_url => burl, :plugin_id => p.id}); 
    return col;
  end 
                                  
   def to_xml(options={})
    options[:indent] ||= 2
    options[:states] ||= nil
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    
    if (!options[:skip_instruct]) then 
      xml.instruct! 
      xml.archival_units do 
        to_xml(options.merge(:skip_instruct => true))
      end
    else
      archival_units_filter_by_states(options[:states]).each do |au| 
        au.to_xml(:builder => xml, :skip_instruct => true, :collection => self)               
      end
    end
  end
  
  def csv_format_description
    params = plugin.param_names(:no_base_url)
    if (params.length == 1) then 
      return "First line must contain '#{params[0]}'"; 
    end
    return  "First line must list parameter names (in any order): '" + 
                "#{plugin.param_names(:no_base_url).join(",")}'"
  end 
  
  def load_aus_from_csv(filename) 
    if (!can_add_aus()) then 
      errors.add "Can not add any more aus to this collection"
      return false;
    end
    params = []; 
    begin 
        params = CSV.read(filename) 
    rescue
        errors.add_to_base  csv_format_description
        return false;
    end
    if (params.length < 1) then 
        errors.add_to_base  "CSV file is empty";
        return false;
    end
    begin 
      param_names = params[0]; 
      for i in (1 ..(params.length() -1))
        hash = {}; 
        for j in (0 .. (param_names.length() -1))
          hash[param_names[j]] = params[i][j]; 
        end
        begin 
          au = ArchivalUnit.new(:param_values => hash, :collection => self); 
          au.save!
        rescue 
          signature = hash.collect{|p,v|  "#{p}=#{v}"}.join(", ") 
          errors.add_to_base("Could not add Au with parameters '#{signature}'")
        end 
      end 
      return (errors.empty?)
     end
   end
   
    def as_json(opts = {})
      extra = {}; 
      extra['archival_units'] = 
             archival_units.collect{ |a| a.id };
      super.as_json(opts ).merge( extra )
    end

   def toStr
     str = "id:#{id} '#{title}' (#{plugin.name} #{base_url})"; 
     str += " remote_id:#{remote_id}" unless remote_id.nil? 
     return str;
    end
  
end
