class ArchiveStatusItem < ActiveRecord::Base
  belongs_to :archive;
  
  validates_presence_of  :archive_id;
  validates_presence_of  :cache;
  validates_presence_of  :size;
  
  # return size in MB 
  def size_mb() 
    return size / 1048576   #(1024 * 1024) 
  end
  
 
  # update  preservation status information of given archive 
  # deletes existing information and updates status of content provider collections 
  # and then propagtes the info 
  # if !StatusMonitor.Active this has the effect of deleting al existing status info 
  def self.update(archive)
    archive.archive_status_items.each {  |cs| cs.delete }
    if (StatusMonitor.active?) then 
      cs = {}; 
      archive.collections.each { |col| 
        col.collection_status_items.each { |csi|
          if (cs[csi.cache].nil?) then 
            cs[csi.cache] = ArchiveStatusItem.new(
                        :archive => archive, 
                        :cache => csi.cache)
          end
          cs[csi.cache].size = cs[csi.cache].size + csi.size;
        }
      }
      cs.each{ |k,v| v.save! } 
    end
  end 
end
