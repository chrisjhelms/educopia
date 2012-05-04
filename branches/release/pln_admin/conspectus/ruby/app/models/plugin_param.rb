# PluginParams  refer to a plugin and have a namem description, and a kind. 
#  * names are unique across parameters of the same plugin 
#  * TODO changing plugin parameters of plugins that have archival unit definitions should be disallowed 
class PluginParam < ActiveRecord::Base
  include ActiveRecordExtension 
  
  belongs_to :plugin;
  validates_presence_of :kind, :name
  validates_uniqueness_of :name, :scope => :plugin_id
  
  # enumeration of allowed parameter kinds
  KINDS = %w(string cardinal url year_4digit volume_no num_issue_range);  
  
  # converts number string to readable parameter kind 
  # based on LOCKSS plugintool usage of enum types 
  def self.toKind(i)
    i = i.to_i;
    return "string" if (i == 1);
    return "cardinal" if (i == 2);
    return "url" if (i == 3);
    return "year_4digit" if (i == 4);
    return "volume_no" if (i == 6);
    return "num_issue_range" if (i == 7);
    return "string";
  end
  
  # * removes extra blanks from name
  # * TODO: make name immutable if plugin has archival_unit
  def name=(str) 
    self[:name] = compact_string(str); 
  end
  
  # * removes extra blanks from name
  # * TODO: make type immutable if plugin has archival_unit
  def kind=(str)
    self[:kind] = compact_string(str); 
  end

  # can't change plugin once param was saved 
  def plugin=(p) 
    if (new_record?) then 
      write_attribute(:plugin_id, p.id) unless p.nil?; 
    else 
      raise "can't change plugin of saved PluginParameter #{name}" if (id)
    end
  end
  
  protected
  # makes sure parameters are attached to saved plugins only 
  def validate
   if (errors.empty?) then 
     if (plugin.nil?) then 
         errors.add_to_base("Plugin may not be nil"); 
     elsif (plugin.new_record?) then 
         errors.add_to_base  "Can't attach to unsaved plugin #{plugin.name}" 
     end 
   end
  end
  
end
