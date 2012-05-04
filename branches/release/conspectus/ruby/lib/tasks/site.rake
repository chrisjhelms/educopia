namespace :site do
  
  require 'tasks/rake_option'
  require 'tasks/task_helper'
  include Task; 
  
  desc "show site info about database and db-user ... "
  task :info do |t|
    if (start_task(t)) then 
      task_trace t, "Parameters:"
      @opts.info(t.to_s + "\t" ); 
      @dbase.config.delete(:password)
      task_trace t, "Database:"; 
      task_trace t, "   #{@dbase.config.inspect}"
    end
  end 
  
  desc "verify minimal requirements in terms of data "
  task :verify  => :environment do |t| 
    if (start_task(t)) then 
      errors = [];
      if (0 == Archive.count) then 
        errors << "Must define at leat one archive"
      end
      if (0 == ContentProvider.count) then 
        errors << "Must define at leat one content provider"
      end
      if (nil == User.find_by_rights("super")) then 
        errors << "Must define at least one user with rights == 'super'"
      end
      if (errors.empty?) then 
        task_trace(t, "All is well"); 
      else 
        errors.each { |e|
          task_trace(t, "ERROR: " + e);
        }
      end
    end
  end 
  
  desc "print available parameter bundles "; 
  task :bundles do  |t|
    bundles = Opts::GLOBALS['RAKE_BUNDLES']; 
    bundles.keys.sort.each do |k| 
      task_trace t, "\t#{k}"
      bundles[k].keys.sort.each do |kk| 
        task_trace t, "\t   #{kk}: #{bundles[k][kk]}"
      end 
    end
  end
  
  def localize_url(url_pattern)
    return  nil if (nil == url_pattern); 
    url = url_pattern.split('?')
    return nil if (0 == url.length) 
    uri = URI.parse(url[0])
    new_url = uri.scheme  + "://localhost" + uri.path; 
    if (2 == url.length) then 
      new_url = new_url + "?" + url[1]
    end
    return new_url;
  end
  
  desc "setup for development"; 
  task :development => [:environment] do  |t|
    if (start_task(t, { "FILE" => ""})) then 
      Rake::Task['db:import'].invoke
      Archive.find(:all).each { |a| 
        a.create_url_pattern = localize_url(a.create_url_pattern); 
        a.update_url_pattern = localize_url(a.update_url_pattern); 
        a.show_url_pattern = localize_url(a.show_url_pattern); 
        a.save!
      }
      Global.find(:all).each { |g|
        if (g.name =~ /^status_monitor/) then 
          g.value = nil;
          g.save!
        end
      }
      Global.set('skin_css', 'development');
    end
  end
  
  
end
