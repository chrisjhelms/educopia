class CollectionStatusItem < ActiveRecord::Base
  belongs_to :collection;
  
  validates_presence_of  :collection_id;
  validates_presence_of  :cache;
  validates_presence_of  :size;
  
  
  # return size in MB 
  def size_mb() 
    return size / 1048576   #(1024 * 1024) 
  end
  
  # summarize collections status in terms of average and total sizes across archival units, sizes in mb
  # give min and max replications and agreement values 
  # numbers are based on archival unit summaries 
  def self.summary(col)
    sum_avg_s = 0; 
    sum_avg_ds = 0; 
    sum_tot_s = 0; 
    sum_tot_ds = 0; 
    mina = nil;
    maxa = nil;
    minrepl = nil; 
    maxrepl = nil; 
    aus = col.archival_units; 
    np = 0;
    for au in aus do 
      summary = PreservationStatusItem.summary(au); 
      repl = summary[:replication]; 
      if (repl > 0) then 
        np  += 1;  
        agree = summary[:avg_agreement]
        if (mina == nil) then 
          mina = maxa = agree;
        else
          mina = agree if agree < mina; 
          maxa = agree if agree > mina; 
        end 
        if (minrepl == nil) then 
          minrepl = maxrepl = repl
        else
          minrepl = repl if repl < minrepl; 
          maxrepl = repl if repl > minrepl; 
        end
        sum_avg_s += summary[:avg_size]; 
        sum_avg_ds += summary[:avg_disk_usage]; 
        sum_tot_s += summary[:total_size]; 
        sum_tot_ds += summary[:total_disk_usage]; 
      end 
    end 
    if (minrepl.nil?) then 
      minrepl = 0; 
      maxrepl  = 0; 
    end 
    return { :n_preserved_aus => np, 
             :avg_size => sum_avg_s, :avg_disk_usage => sum_avg_ds, 
             :total_size => sum_tot_s, :total_disk_usage => sum_tot_ds, 
             :min_agreement => mina, :max_agreement => maxa, 
             :min_repl => minrepl, :max_repl => maxrepl } 
  end

  # update  preservation status information of given collection 
  # deletes existing information and propagates info from archival units
  # if !StatusMonitor.Active this has the effect of deleting al existing status info 
  # size is really sum_size across aus 
  def self.update(collection)
    collection.collection_status_items.each {  |cs| cs.destroy }
    if (StatusMonitor.active?) then 
      cs = {}; 
      collection.archival_units.each { |au| 
        au.preservation_status_items.each { |aus|
          if (cs[aus.cache].nil?) then 
            cs[aus.cache] = CollectionStatusItem.new(
                        :collection => collection, :cache => aus.cache)
          end
          cs[aus.cache].size += aus.size;
          cs[aus.cache].disk_usage += aus.disk_usage;
        }
      }
      #cs.each{ |k,v| puts "#{k} => #{v.id} #{v.size}"} 
      cs.each{ |k,v| v.save!} 
      #cs.each{ |k,v| puts "#{k} => #{v.id} #{v.size}"} 
      collection.reload
    end 
  end
end
