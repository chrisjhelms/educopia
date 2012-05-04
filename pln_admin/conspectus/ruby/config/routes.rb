ActionController::Routing::Routes.draw do |map|
  #puts map.class.inspect; 
  
  def named_connect(map, url, hash) 
    name = "#{hash[:controller]}_#{hash[:action]}"; 
    map.send(name.intern, url, hash); 
  end
  
  map.connect ':controller/find/:name/*rest', :action => :find 
  named_connect map, ":controller/search", :action => :search, :conditions => { :method => :get }
  named_connect map, ":controller/search", :action => :search, :conditions => { :method => :post }
  
  map.root :controller => 'user_sessions', :action => :go_home;
  
  map.application_test_html  'test', 
              :controller => 'application', 
              :action => 'show_html',
              :conditions => { :method => :get }

  map.guess_pwd_user_session 'users/guess', 
              :controller => 'users',
              :action => 'guess_pwd',
              :conditions => { :method => :get }
  map.resources :users
              
  map.resource :user_session
  map.new_user_session_with_rights  'user_session/new/:rights', 
              :controller => 'user_sessions', 
              :action => 'new',
              :conditions => { :method => :get }
  map.new_guess_pwd_user_session 'user_session/new_guess_pwd', 
              :action => 'new_guess_pwd',
              :controller => 'user_sessions', 
              :conditions => { :method => :get }
  map.guess_pwd_user_session 'user_session/guess', 
              :controller => 'user_sessions',
              :action => 'guess_pwd',
              :conditions => { :method => :post }
  map.login_or_show_user_session  "/login_or_profile",
              :controller => 'user_sessions',
              :action => 'new_or_profile', 
              :conditions => { :method => :get }
 
  map.resources(:globals); 
  
  
  #############################################################################
  # MAPPING /archives routes 
  #############################################################################  
  ["/austates/:states", "/austates/:states.:format", ".:format"].each do |params|
    named_connect  map, "archives/:id/archival_units#{params}",
    :controller => :archives,
    :action => :archival_units,
    :conditions => { :method => :get }
  end

  ["/state/:state", ""].each do |params|
    named_connect map, "archives/:id/show#{params}",
    :controller => :archives,
    :action => :show,
    :conditions => { :method => :get }
  end
  ["/state/:state", ""].each do |params|
    named_connect map, "archives/:id/plugins#{params}",
    :controller => :archives,
    :action => :plugins,
    :conditions => { :method => :get }
  end 
 
  map.resources :archives; 
  
  #############################################################################
  # MAPPING /content_providers routes 
  #############################################################################
  ["/austates/:states", "/austates/:states.:format", ".:format"].each do  |params|
    named_connect map, "content_providers/:id/archival_units#{params}",
    :controller => :content_providers,
    :action => :archival_units,
    :conditions => { :method => :get }
  end

  ["/state/:state", ""].each do |params|
    named_connect map, "content_providers/:id/show#{params}",
    :controller => :content_providers,
    :action => :show,
    :conditions => { :method => :get }
  end

  ["/state/:state", ""].each do |params|
    named_connect map, "content_providers/:id/plugins#{params}",
    :controller => :content_providers,
    :action => :plugins,
    :conditions => { :method => :get }
  end 

  map.resources :content_providers; 
  
  #############################################################################
  # MAPPING /plugins routes 
  #############################################################################
    ["/austates/:states.:format", ".:format"].each do |params|
       named_connect map, "plugins/:id/archival_units#{params}", 
                :controller => :plugins,
                :action => :archival_units,
                :conditions => { :method => :get }
    end
    named_connect map,  "plugins/:id/retire/:ret_bool", 
                :controller => :plugins,
                :action => :retire,
                :conditions => { :method => :post }
  
  [:mine, :all_or_mine, :index].each do |act| 
    ["/state/:state", ""].each do |params|
    named_connect map,  "plugins/#{act}#{params}", 
                  :controller => :plugins,
                  :action => act,
                  :conditions => { :method => :get }
    end 
  end
  
  map.resources :plugins, :has_many => :plugin_params;
  map.destroy_plugin_plugin_param 'plugins/:plugin_id/plugin_params/:id/destroy', 
                :controller => 'plugin_params', 
                :action => 'destroy', 
                :conditions => {:method => :delete }
  
  #############################################################################
  # MAPPING /collections routes 
  #############################################################################
  [:mine, :all_or_mine, :index].each do |act| 
    ["/state/:state", ""].each do |params|
       named_connect map, "collections/#{act}#{params}.:format", 
                  :controller => :collections,
                  :action => act,
                  :conditions => { :method => :get }
      
    end
  end 
                  

    ["/austates/:states", ""].each { |params| 
      named_connect map,  "collections/:id/manage_aus#{params}", 
                :controller => :collections,
                :action => :manage_aus,
                 :conditions => { :method => :get }
    } 
   
    named_connect map,  "collections/:id/retire/:ret_bool", 
                :controller => :collections,
                :action => :retire,
                 :conditions => { :method => :post }
    
    named_connect map,  "collections/:id/metadata.xml", 
                :controller => :collections,
                :action => :metadata,
                :conditions => { :method => :get}, 
                :format => 'xml'

  
  
  map.set_au_states_collections 'collections/:id/au', 
              :controller => 'collections', 
              :action => :set_au_states,
              :conditions => { :method => :post }
    
  map.upload_aus_collections 'collections/:id/au/upload', 
              :controller => 'collections', 
              :action => :upload_aus,
              :conditions => { :method => :get }
  
  map.upload_aus_from_file_collections 'collections/:id/au/upload', 
              :controller => 'collections', 
              :action => :upload_aus_from_file,
              :conditions => { :method => :post }
  
  map.new_au_collections 'collections/:id/au/new', 
              :controller => 'collections', 
              :action => :new_au,
              :conditions => { :method => :get }
  map.new_au_collections 'collections/:id/au/create', 
              :controller => 'collections', 
              :action => :create_au,
              :conditions => { :method => :post }
  map.destroy_au_collections 'collections/:id/au/:au_id/del', 
              :controller => 'collections', 
              :action => :destroy_au,
              :conditions => { :method => :delete }
  map.view_status_au_collections 'collections/:id/au/:au_id', 
              :controller => 'archival_units', 
              :action => :status,
              :conditions => { :method => :get }
  map.destroy_aus_collections 'collections/:id/del_aus/state/:states', 
              :controller => 'collections', 
              :action => :destroy_aus,
              :conditions => { :method => :delete }
  
  map.resources :collections;

  # :manage_aus, :status - with low-prio routes   
  #############################################################################
  # MAPPING /archival_units
  #############################################################################
  ["/austates/:states.:format", ".:format"].each do |params|
    map.connect  "archival_units#{params}", 
                    :controller => :archival_units,
                    :action => :index,
                    :conditions => { :method => :get }
  end  

  map.update_lockss_au_ids 'archival_units/update_lockss_au_ids.:format', 
              :controller => 'archival_units', 
              :action => :get_lockss_au_ids,
              :conditions => { :method => :get }
  map.update_lockss_au_ids 'archival_units/update_lockss_au_ids.:format', 
              :controller => 'archival_units', 
              :action => :update_lockss_au_ids,
              :conditions => { :method => :post }
  map.update_lockss_au_ids_from_url 'archival_units/update_lockss_au_ids_from_url.:format', 
              :controller => 'archival_units', 
              :action => :update_lockss_au_ids_from_url,
              :conditions => { :method => :post }

  map.connect "archival_units/:au_id.:format", 
              :controller => 'archival_units', 
              :action => :show,
              :conditions => { :method => :get }
  map.connect "archival_units/:au_id/:action.:format", 
              :controller => 'archival_units', 
              :conditions => { :method => :get }

  map.connect ':controller/:id/:action.:format', :conditions => { :method => :get }

end
