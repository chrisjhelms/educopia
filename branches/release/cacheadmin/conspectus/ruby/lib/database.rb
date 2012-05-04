
require 'erb'
require 'active_record'

class Database
  
  MYSQLDUMP = "mysqldump"; 
  MYSQL = "mysql"
  
  attr_reader( :config) 
  
  def inspect 
    # TODO remove passord listing 
    super.inspect; 
  end
  
  def initialize(railsenv) 
    f = File.new("#{RAILS_ROOT}/config/database.yml");  
    erb = ERB.new(f.read);
    yaml  = YAML.load(erb.result);    
    if (!yaml.key?(railsenv)) then  # seems like it should never happen 
      raise "no such db environment #{railsenv}"
    end
    @config = yaml[railsenv].symbolize_keys; 
    ActiveRecord::Base.establish_connection(@config);
  end
  
  def config
    return @config
  end
  
  def dumpcmd(dbtables)       
    cmd = "UNDEFINED";
    if (@config[:adapter] == "mysql") then 
      cmd = "#{MYSQLDUMP} -u#{@config[:username]} -p#{@config[:password]} "; 
    else
      raise "can't dump #{@config[:adapter]} databasees"
    end 
    
    [:host, :port, :socket].each do |arg|
      if (@config[arg]) 
        cmd << " --#{arg}=#{@config[arg]} "
      end 
    end
    cmd << " #{@config[:database]} #{dbtables.join(" ")}";
    return cmd;
  end
  
  
   def importcmd(file)       
    cmd = "UNDEFINED";
    if (@config[:adapter] == "mysql") then 
      cmd = "#{MYSQL} -u#{@config[:username]} -p#{@config[:password]} "; 
    else
      raise "can't import #{@config[:adapter]} databasees"
    end 
    
    [:host, :port, :socket].each do |arg|
      if (@config[arg]) 
        cmd << " --#{arg}=#{@config[arg]} "
      end 
    end
    cmd << " #{@config[:database]}";
    if (file =~ /\.SQL$/i) then 
      return "cat #{file} | #{cmd}";
    else 
      return "zcat #{file} | #{cmd}";
    end
  end
  
  
  def optimize(dbtables) 
    return if dbtables.empty?
    case @config[:adapter]
      when 'mysql'
      for job in %w(CHECK REPAIR ANALYZE OPTIMIZE)
        jobcmd = "#{job} TABLE #{dbtables.join(',')}";
        puts jobcmd;
        ActiveRecord::Base.connection.execute(jobcmd)
      end
    else
      puts "The Cache Manager doesn't handle optimization for your database type."
    end
  end
  
end 
