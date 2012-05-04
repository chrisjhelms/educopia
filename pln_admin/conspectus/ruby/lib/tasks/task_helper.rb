module Rake
  class Task
    def to_s
      return "[" + name + "]"; 
    end
    
  end
  
end


module Task 
  require "lib/database"; 
  
  # start task by parsing commandline args and merging with default values given in opts hash 
  def start_task(t, opts = {})
    task = t.name; 
    @ret = 0; 
    @opts = RakeOption.new(t.name, opts);
    @dbase = Database.new(@opts['RAILS_ENV']); 
    @dry_run = @opts['DRY_RUN'] == "true";
    @silent = @opts['RAILS_SILENT'] == "true";
    
    if (!@silent) then
      task_trace t, ">> ------------------------"
      task_trace t, ">> #{Time.now}"
      @opts.each{ |k,v| task_trace(t, ">> #{k}=#{v}")}
      task_trace t,  ">> ------------------------"
      if (@dry_run) then
        @opts.each{ |k,v| task_trace(t, " * #{k}=#{v}")}
      end
    end
    return !@dry_run
  end
  
  def task_get_au_states(pname, opts) 
    states = AuState.getList(opts[pname])
    if (states.empty?) then 
      $stderr.print "#{pname} parameter must contain comma separated list of valid AuState names\n"
      return []; 
    end
    return states; 
  end
  
  def task_get_content_provider(pname, opts) 
    val = nil; 
    if (opts[pname] != '') then 
      val = ContentProvider.find_by_acronym(opts[pname])
      if (val.nil?) then 
        $stderr.print "#{t}: #{pname} parameter must contain valid Content Provider acronym\n";
        $stderr.print "#{t}: \tavailable acronyms: #{ContentProvider.find(:all).collect{ |c| c.acronym}.join(',')}\n";
      end
    end
    return val; 
  end
  
  def task_trace(t, *strs)
    strs.each{ |str| puts "#{t}: #{str}"} 
  end 
  
  def task_get_archive(pname, opts) 
    val = nil; 
    if (opts[pname] != '') then 
      val = Archive.find_by_title(opts[pname])
      if (val.nil?) then 
        $stderr.print "#{pname} parameter must contain valid Archive\n";
        $stderr.print "\tavailable acchives: #{Archive.find(:all).collect{ |c| c.title}.join(',')}\n";
      end
    end
    return val; 
  end
end
