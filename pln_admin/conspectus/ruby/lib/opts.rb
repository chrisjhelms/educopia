
class Opts < Hash
  
  attr_reader(:name);
  
  def initialize(name, hash)
    super();
    @name = name;
    hash.each { |k,v| self.store(k,v); }
  end
  
  def [](key)
    if (!key?(key)) then
      raise "#{key} not a key in #{@name}";
    end
    return fetch(key);
  end
  
  def merge(hash)
      hash.each { |k,v| self.store(k,v) if key?(k) }
      return self
  end
  
  def info(pre = "")
    lines = ""; 
    self.each {|key, value| lines <<  "#{pre}#{key}: #{value}"}
    return lines;
  end
  
  def self.all_info 
      puts "All_info"
      GLOBALS.each { |k, v| puts "#{k}: #{v.class} #{v.inspect}"}
      puts "---"
  end
  GLOBALS = {}; 

end
