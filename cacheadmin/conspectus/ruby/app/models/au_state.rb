# Plugins have a name and refer to a ContentProvider
# Their name must begin with the content_provider's plugin_prefix.
# Plugins are created/retrieved with Plugin.get
class AuState < ActiveRecord::Base
  include ActiveRecordExtension 
  
  has_many :archival_units;
  validates_uniqueness_of :name, :level; 
  
  private
      @@cache = {}; 
      @@irreversible_states = nil;
      @@reversible_states = nil;
  

  public
 
  DRAFT = "draft"; 
  TEST = "test";
  PRESERVED = "preserved"; 
  RETEST = "retest";
  RETIRED = "retired"; 
  
  # use one of the constants DRAFT, ... RETIRED for name parameter
  def self.get(name) 
    if (!@@cache[name])  then 
        @@cache[name] =  self.find_by_name(name); 
    end 
    return @@cache[name]
  end
  
  def self.getList(names) 
    sts = names.split(","); 
    states = sts.collect{ |s| AuState.get(s); }.flatten;
    states.delete(nil); 
    return states
  end
  
  def self.names 
    return  self.find(:all, :order => :level).collect{|s| s.name}
  end
  
  # depending on rervsibles_only paramater return all states or reversible only states 
  def self.getStates(reversibles_only)
    reversibles_only ? reversibles : AuState.find(:all, :order => :level);  
  end
  
  def self.irreversibles
    if (@@irreversible_states.nil?) then 
      @@irreversible_states = self.find(:all, :conditions => "irreversible = true")
    end
    return @@irreversible_states;
  end
  
   def self.reversibles
    if (@@reversible_states.nil?) then 
      @@reversible_states = self.find(:all, :conditions => "irreversible = 0")
    end
    return @@reversible_states;
  end
  
  def irreversible?() 
    return irreversible;
  end
  
  def test?() 
    return (name == TEST) || (name == RETEST);
  end
  
  def retired?() 
    return (name == RETIRED); 
  end
  
  # use one of the constants DRAFT, ... RETIRED for state parameter
  def isState?(state) 
    return name == state;
  end
  
  # check whether a transition to the new state st2 should be allowed 
  # @param with_super_power indicates whether caller is privileged 
  # privilileged callers may change states at will 
  # non privileged callers may transition into reversible states only 
  # non privileged Callers may not transition out of an irreversible state 
  def allow_transition_to(st2, with_super_power) 
    return true if (with_super_power)

    # regular usser 
    return true if self == st2

    # retest state is special 
    return true if (self.name == "retest") && (st2.name == "preserved");
    return true if (self.name == "preserved") && (st2.name == "retest");
    # otherwise regular never touches irreversible states 
    return false if (st2.irreversible? || self.irreversible?)  
    
    # if both states are reversible anything goes 
    return true; 
  end 

  def self.reset(site)
    puts "LOADING config/data/#{site}/au_states.yml"
    states = YAML.load_file("config/data/#{site}/au_states.yml")
    states.each { |k,h| 
      h["irreversible"] = (h["irreversible"] != 0); 
      st = AuState.find_by_name(h["name"]); 
      if st.nil? then 
        st = AuState.new(h);
      else
        st.attributes= h;
      end 
      if (!st.save(false)) then 
        $stderr.puts AuState.errors.inspect; 
      end
    }
    AuState.find(:all).each { |st| puts "  " + st.inspect } 
  end
  
   # for tracing/debugging 
   def self.put_cached
    puts "CACHED_STATES " + @@cache.inspect; 
    puts "IRREVERSIBLES " + @@irreversible_states.inspect; 
    puts "  REVERSIBLES " + @@reversible_states.inspect; 
  end
  
end
