require 'database';

class Setup 
  
  def configure
    begin 
      ENV['RAILS_SILENT'] = "true" 
      get_env();  
      if (true) then 
      create_env_file
      create_database_yml  
      create_database(@rails_env)
      create_database("test")
      enhance(@rails_env)
      end 
      create_users()
      verify();
      puts ""
      puts "SUCCESS"
    rescue Exception => e
      STDERR.puts("Something went seriously wrong, please contact support@metaarchive.org"); 
      STDERR.puts("Did you give the correct database credentials ? "); 
      STDERR.puts("Contact support@metaarchive.org if you need assistance "); 
      STDERR.puts(e.inspect); 
      STDERR.puts e.backtrace
      exit(1)
    end
  end  
  
  def enhance(env = nil)
    ENV['RAILS_SILENT'] = "true" 
    if (env.nil?) then get_env() end   
    create_archives()
    create_content_providers()
  end  
  
   def verify() 
    puts "";
    puts "*** verify minimal requirements"
    systm "rake site:verify"
    if ("yes" == prompt("did you see errors?  (yes/no)")) then 
        raise "you need to rerun this script and fill in the missing pieces" 
    end
  end
  
  
  def create_users() 
    puts "";
    userfile = "./config/data/users.yml";
    puts "creating conspectus users from info in #{userfile}"
    systm "rake user:load RESET_PWD=true FILE=#{userfile}"
    puts "user info and password: "
    systm "cat " + userfile; 
    puts "you will be able to create more users by login in as the admi user"
    puts "or you can use rake user:load to load users from a yml file"
  end
  
  def create_content_providers()
    puts "";
    puts "*** existing content providers"
    systm "rake content_provider:list"
    while ("yes" == prompt("add a content provider ? (yes/no)")) do 
      name = prompt_value("content provider name")
      acro = prompt_value("content provider acronym (at most 4 chars)")
      favicon = prompt_value("url of favicon (leave empty for default value)", "")
      plugin_pre = prompt_value("plugin prefix - eg edu.home", "")
      stmt = "rake content_provider:create 'NAME=#{name}' " + 
               "'ACRONYM=#{acro}' 'PLUGIN=#{plugin_pre}' ";
      if (favicon != "") then 
        stmt = stmt + " 'ICON_URL=#{favicon}'"
      end
      systm stmt
      systm "rake content_provider:list"
    end
  end
  
  def create_archives() 
    puts "";
    puts "*** existing archives"
    systm "rake archive:list"
    while ("yes" == prompt("add an archive ? (yes/no)")) do 
      name = prompt_value("archive acronym (up to 5 chars)",  "GEN")
      descr = prompt_value("archive title ", "General Purpose Archive")
      systm("rake archive:create 'NAME=#{name}' 'DESCR=#{descr}'")  
      systm "rake archive:list"
    end
  end
  
  def create_database(env) 
    puts "";
    puts "*** initializing database for environment #{env}"; 
    system "rake db:info RAILS_ENV=#{env}"
    if ("yes" == prompt("zap and recreate the database for #{env}? (yes/no)")) then
      systm("rake db:drop db:create db:migrate RAILS_ENV=#{env} --trace"); 
      puts ("\n*** A summary of database content should show zero records everywhere")
      systm("rake db:info RAILS_ENV=#{env}"); 
      if ("no" == prompt("did you see lots of zeros ?  (yes/no)")) then 
        raise "something went seriously wrong" 
      end
    end
  end
  
  def  create_database_yml
    puts "";
    puts "*** database configuration file"; 
    
    fname = @rails_root + "/config/database.yml"; 
    if (File.exists?(fname)) then 
      system("cat  #{fname}"); 
      if ("yes" == prompt("keep database settings ? (yes/no)")) then 
        return;
      end
    end
    @dbname = prompt_value("production database name", @dbname ||  "pln_production")
    @dbname_test = prompt_value("test database name", @dbname_test || "#{@dbname}_test")
    @dbuser = prompt_value("database user", @dbuser || ENV['USER'])
    @dbpwd = prompt_value("database password", @dbpwd)
    
    @socket = nil;
    ["/var/lib/mysql/mysql.sock", "/var/run/mysqld/mysqld.sock"].each { |s| 
      if (File.exists?(s)) then @socket = s; end   
    }
    if (nil == @socket) then 
      raise "can't find the mysql db socket file"
    end
    puts "*** creating #{fname}";
    puts "*** you can  change entries later by rerunning the crsipt or by editing"; 
    file = File.open(fname, 'w')
    file.write( 
      { @rails_env => {
                  "database" => @dbname, 
                  "username" => @dbuser, 
                  "password" => @dbpwd,
                  "adapter" => "mysql",
                  "socket" => @socket
      }, 
      @rails_env_test => {
                  "database" => @dbname_test, 
                  "username" => @dbuser, 
                  "password" => @dbpwd,
                  "adapter" => "mysql",
                  "socket" => @socket
      }
    }.to_yaml);
    file.close;
    create_database_yml
  end
  
  def  create_env_file
    puts "";
    puts "*** rails environment files";
    
    fname = @rails_root + "/config/environments/" + @rails_env + ".rb"; 
    if (!File.exists?(fname)) then 
      templ = @rails_root + "/config/environments/production.rb"; 
      puts "*** creating #{fname}"
      system("cp  #{templ} #{fname}");
    else 
      puts "*** exists #{fname}"
    end
    fname = @rails_root + "/config/environments/" + @rails_env_test + ".rb"; 
    if (!File.exists?(fname)) then 
      templ = @rails_root + "/config/environments/test.rb"; 
      puts "** creating #{fname}"
      system("cp  #{templ} #{fname}"); 
    else 
      puts "*** exists #{fname}"
    end
  end
  
  def get_env 
    @rails_env = ENV['RAILS_ENV'] || "";
    @rails_root = ENV['PWD']
    @rails_env = prompt_value("rails_env", @rails_env || "production")
    @rails_env_test = "test";
    ENV['RAILS_ENV'] = @rails_env;  
    trace_state
  end
  
  def prompt(str)
    STDOUT.print  ": " + str + " > "; 
    STDOUT.flush
    return STDIN.readline.chop; 
  end
  
  def prompt_value(name, val ="") 
    if (val == "") then 
      val = prompt("\tenter #{name}")
    else
      puts ": #{name} = #{val}"; 
      other_val = prompt( "\treturn or enter #{name}"); 
      if (other_val != "") then 
        val = other_val; 
      end
    end
    return val; 
  end

  def systm(cmd) 
    puts ">> #{cmd}"
    system(cmd); 
    puts "<< ---"
  end
  
  def trace_state
    puts ""
    puts "*** RAILS_ENV: #{@rails_env}";  
    puts "*** RAILS_ROOT: #{@rails_root}"; 
  end
end 

