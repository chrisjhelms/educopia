namespace :plugin do
  require 'find'
  
  require 'rexml/document'
  
  require 'tasks/rake_option'
  require 'tasks/task_helper'
  include Task; 
  
  
  desc "cleanup base_url parameter comments"; 
  task :cleanup_base_url_params => :environment do |t|
    if (start_task(t, {})) then 
      params = PluginParam.find(:all, :conditions => { :name => "base_url" } );     
      for p in params do 
         p.descr = "Usually if the form http://.. or https://.."; 
         p.save!
      end 
    end 
  end 
  
end
