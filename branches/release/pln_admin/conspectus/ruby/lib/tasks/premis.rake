namespace :premis do
  require 'tasks/rake_option'
  require 'tasks/task_helper'
  include Task;
  
  # update directories in ./public/premis
  desc "update premis diretory"
  task :update=>  [:environment]  do |t| 
    if (start_task(t, {"MAPREMIS" => "", 
			"CONSPECTUS" => "http://conspectus.metaarchive.org"})) then 
      co_url = @opts[ 'CONSPECTUS']; 
      dir = @opts[ 'MAPREMIS']; 
      for c in Collection.find(:all) do
        cdir = "#{dir}/#{c.id}"; 
        if (!File.directory?(cdir)) then 
	     systm("mkdir #{cdir}"); 
	end
        if (File.directory?(cdir)) then 
		begin 
			out = File.open("#{cdir}/README.txt", "w"); 
			out.puts "#{co_url}/collections/#{c.id}" + "\n";
			out.puts c.archive.title + "\n";
			out.puts c.title + "\n";
	        	out.puts c.base_url + "\n"; 
			out.puts c.plugin.name + "\n"; 
			out.close;
		rescue  Exception => e
			puts  e.inspect;
		end
	end
      end
    end
  end

  def systm(cmd) 
    puts ">> #{cmd}"
    rc = system(cmd); 
    puts "<< ---"
    return rc;
  end
  
end
