class ContentProviderStatusItem < ActiveRecord::Base
  belongs_to :content_provider;
  
  validates_presence_of  :content_provider_id;
  validates_presence_of  :cache;
  validates_presence_of  :size;
  
  # return size in MB 
  def size_mb() 
    return size / 1048576   #(1024 * 1024) 
  end
  
 
  # update  preservation status information of given content_provider 
  # deletes existing information and updates status of content provider collections 
  # and then propagtes the info 
  # if !StatusMonitor.Active this has the effect of deleting al existing status info 
  def self.update(content_provider)
    content_provider.content_provider_status_items.each {  |cs| cs.delete }
    if (StatusMonitor.active?) then 
      cs = {}; 
      content_provider.collections.each { |col| 
        col.collection_status_items.each { |csi|
          if (cs[csi.cache].nil?) then 
            cs[csi.cache] = ContentProviderStatusItem.new(
                        :content_provider => content_provider, 
                        :cache => csi.cache)
          end
          cs[csi.cache].size = cs[csi.cache].size + csi.size;
        }
      }
      cs.each{ |k,v| v.save! } 
    end
  end 
end
