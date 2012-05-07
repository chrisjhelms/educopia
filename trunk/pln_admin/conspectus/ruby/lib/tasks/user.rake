namespace :user do
  require 'tasks/rake_option'
  require 'tasks/task_helper'
  include Task; 
  
  desc "load from yml file"
  task :load  => :environment do |t|
    if (start_task(t, {"FILE" => "", "RESET_PWD" => "false"})) then 
      User.load(@opts["FILE"], @opts["RESET_PWD"] == "true")
    end
  end
  
  desc "delete all users [fomr content_provider]"
  task :delete_all  => :environment do |t|
    if (start_task(t, {"CONTENT_PROVIDER" => ""})) then 
      acro = @opts["CONTENT_PROVIDER"]; 
      if (acro.empty?) then 
        $stderr.puts "Must give CONTENT_PROVIDER"
        exit 1;
      end 
      cp = ContentProvider.find_by_acronym(acro)
      if (cp.nil?) then 
        $stderr.puts "Could not find CONTENT_PROVIDER with acronym #{acro}"
        exit 1;
      end
      us = cp.users; 
      us.each { |u| task_trace t, "delete user #{u}"; u.delete; } 
    end
  end
  
  desc "delete user from user_name"
  task :delete  => :environment do |t|
    if (start_task(t, {"LOGIN" => ""})) then 
      login = @opts["LOGIN"]; 
      if (login.empty?) then 
        $stderr.puts "Must give LOGIN and PASSWORD"
        exit 1;
      end 
      u = User.find_by_login(login); 
      if (u.nil?) then 
        $stderr.puts "No such user: #{login}"; 
        exit 1; 
      end
      task_trace t, "Delete user #{login}"; 
      u.delete; 
    end
  end
  
  desc "list users"
  task :list  => :environment do |t|
    if (start_task(t, {"ROLE" => nil})) then 
      role = @opts["ROLE"];   
      us = User.find(:all); 
      us.each { |u| task_trace t, u } 
    end
  end
  
end
