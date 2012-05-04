namespace :global do
  require 'tasks/rake_option'
  require 'tasks/task_helper'
  include Task; 
  
  desc "list global settings"; 
  task :list  => :environment do |t|
    if (start_task(t, {})) then 
      for g in  Global.find(:all) do 
        task_trace(t, g.name + "\t= " + (g.value || "") ); 
      end
    end
  end
  
  desc "list global settings"; 
  task :set  => :environment do |t|
    if (start_task(t, {"NAME" => "", "VALUE" => ""})) then 
      name = @opts['NAME'];
      value = @opts['VALUE'];
      if (name == "") then 
        $stderr.puts "Must give NAME parameter"
        exit 1; 
      end
      if (Global.set(name, value)) then 
          task_trace t,  "#{name} = '#{value}'" ;
      else 
        task_trace t,  "FAILED to assign @{name} = '@{value}'" ;
      end
    end
  end
  
end
