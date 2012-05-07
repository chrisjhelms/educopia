class PreservationStatusItem < ActiveRecord::Base
  belongs_to :archival_unit;
  
  validates_presence_of  :archival_unit_id;
  validates_presence_of  :cache;
  #validates_presence_of :hostname;
  #validates_presence_of :ui_port;
  validates_presence_of  :disk_usage;
  validates_presence_of  :size;
  #validates_presence_of :last_crawl;
  #validates_presence_of :last_crawl_result;
  #validates_presence_of :last_crawl_attempt;
  #validates_presence_of :last_poll;
  validates_presence_of  :num_recent_polls;
  
  def self.get(hash) 
    logger.debug("CAU HASH #{hash.inspect}")   
    hash.keys.each do |k| 
      if (k.class == String) then hash[k.to_sym] = hash.delete(k); end 
    end
    
    pi = PreservationStatusItem.find(:first, :conditions => { :cache => hash[:cache], :archival_unit_id => hash[:archival_unit_id] } ); 
    if (pi.nil?) then 
      pi = new(hash)
    else  
      pi.update_attributes(hash); 
    end 
    return pi;
  end
  
  class << self
      protected :new
  end
  
  # return size in MB
  def size_mb 
    return size / 1048576 # (1024 * 1024) 
  end
  
  # return disk_usage in MB
  def disk_usage_mb 
    return disk_usage 
  end
  
  # summarize aus status in terms of average and total sizes, and agreement  , sizes in mb
  def self.summary(au)
    items = au.preservation_status_items
    repl = items.length; 
    return { :avg_size =>  0, :avg_disk_usage => 0, :avg_agreement =>  0, 
             :total_size => 0 , :total_disk_usage => 0, 
             :replication => 0 }  if repl == 0; 

    s = 0;  
    ds = 0; 
    a = 0.0;  na = 0; 
    for st in items do 
      s += st.size; 
      ds += st.disk_usage; 
      begin 
        a += st.agreement;
        na += 1; 
      rescue  
        # undefined agreement 
        # not counting towards average 
      end
    end 
    s = s / 1048576; 
    return { :avg_size => s / repl, :avg_disk_usage => ds / repl, :avg_agreement => a / na, 
             :total_size => s , :total_disk_usage => ds, 
             :replication => repl }
  end

  # retrieve status data for au from givenmonitor url 
  # return -1 or the number of replication reported 
  def self.update_archival_unit(au, logger, mon =  StatusMonitor.au_status_url)  
    repl = -1
    if (au.lockss_au_id.nil?) then 
      raise "Unknown Lockss Au Id"
    end
    data = NetData.new(mon, "post", { :au_id =>  au.lockss_au_id, :exact_match => "true" }, logger )
    doc = REXML::Document.new(data.body);
    aus = doc.elements.to_a("/archival_units/archival_unit")
    if (aus.length > 1) then 
      raise "WARNING: multiple matches returned"
    else 
      if (aus[0].nil?) then 
        repl = 0; 
      else 
        repl = digestStatusXml(au, aus[0])
      end
    end
    au.reload 
    return repl
  end
  
  def self.update_archival_unit_from_xml(au, xml)
    return  PreservationStatusItem.digestStatusXml(au, xml)
  end
  

  private
  
  def self.digestStatusXml(au, xml)
    caus = xml.elements.to_a("cache_archival_units/cache_archival_unit")
    nitems = caus.length;
    if (!caus.empty?) then     
      caus.each { |cau| 
        cauhash = Hash.from_xml(cau.to_s)["cache_archival_unit"];   
        cauhash.delete('id'); 
        cauhash.delete('lockss_au_id'); 
        begin 
          pi = PreservationStatusItem.get(cauhash.merge({:archival_unit_id => au.id}));
          pi.save!
        rescue Exception => e
          raise "XML formatting error in cache_archival_unit element\n#{pi.inspect}\n"; 
          nitems = nitems -1;
        end
      }
    end
    return nitems;
  end
end
