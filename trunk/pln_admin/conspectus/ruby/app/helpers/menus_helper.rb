module MenusHelper
 
  def collection_obj_menu(params, collection)
    return "" if collection.nil? ; 
    
    subsubmenu = sub_item(collection, 'Edit', 
                       :controller => 'collections', 
                       :action => :edit, 
                       :id => collection) ; 
    if (!collection.empty? || collection.can_add_aus) then 
      subsubmenu += collections_manage_aus_menu(collection) ; 
    end
    subsubmenu += sub_item(collection, 'Status',  
                        :controller => :collections, 
                        :action => :status,
                        :id => collection); 
    subsubmenu  += del_item(collection, 'Delete', 
                 {:controller => :collections, :action => :destroy, :id => collection}, 
                 { :method => :delete, :confirm => "Are you sure you want to delete this collection ?"}); 
    if (subsubmenu != "") then 
      submenu = "" +
      m_sel_item( "Collection #{collection.id}" , 
                        :controller => 'collections', 
                        :action => :show,
                        :id => collection); 
      submenu += subsubmenu; 
    end
    
 
    supermenu = states_submenu(collection,  'Manage Aus', :controller => :collections, 
                         :action => :manage_aus, 
                         :id => collection );
    submenu += super_block(supermenu); 
    supermenu = sub_item(collection, 'Retire',    { :controller => :collections, 
                          :action => :retire,
                          :id => collection, 
                          :ret_bool => "true"}, 
                          { :method => :post }  ); 
    supermenu += sub_item(collection, 'Unretire',  
                      { :controller => :collections, 
                          :action => :retire,
                          :id => collection, 
                          :ret_bool => "false"}, 
                      { :method => :post }  ); 
    supermenu = super_block(supermenu);                    
    
    #return s_item_html(submenu); 
    return submenu + supermenu
  end
  
  def collections_manage_aus_menu(collection)
    sel = @managing_aus; 
    menu = sub_item(collection, 'Manage AUs',
                         :controller => :collections, 
                         :action => :manage_aus, 
                         :id => collection); 
    submenu = ""; 
    
    submenu =  sub_item(collection, 'Add Single',  
                       :controller => :collections, 
                       :action => :new_au, 
                       :id => collection);
    submenu += sub_item(collection, 'Add Several',
                       :controller => :collections, 
                       :action => :upload_aus, 
                       :id => collection) ;
    submenu += del_item(collection, 'Delete Draft',  {:controller => :collections, 
                        :action => :destroy_aus, 
                        :states => AuState::DRAFT,
                        :id => collection}, { :method => :delete, 
                          :confirm => "Are you sure you want to delete ALL DRAFT archival units ?"})  ;
    submenu += del_item(collection, 'Delete Test',  {:controller => :collections, 
                          :action => :destroy_aus, 
                          :states => AuState::TEST, 
                          :id => collection},   { :method => :delete, 
                          :confirm => "Are you sure you want to delete ALL TEST archival units ?"});
    menu += s_item_html(submenu) unless submenu == "";
    return menu;
  end
  
  def plugin_obj_menu(params, plugin) 
    return "" if plugin.nil? ; 
    if (params['controller'] == 'plugins') then  
      submenu = "";
      submenu += sub_item(plugin,  'Edit', 
                           :controller =>  :plugins,
                           :action => :edit, 
                           :id => plugin);
      submenu += del_item(plugin,  'Delete',  
      {:controller => :plugins, :action => :destroy, :id => plugin}, 
      { :method => :delete, :confirm => "Are you sure you wantto delete this plugin ?"}); 
      
      super_submenu = ""; 
      super_submenu += sub_item(plugin, 'Retire',  
      { :controller => :plugins, 
                          :action => :retire,
                          :id => plugin, 
                          :ret_bool => "true"}, 
      { :method => :post }  ); 
      super_submenu += sub_item(plugin, 'Unretire',  
      { :controller => :plugins, 
                          :action => :retire,
                          :id => plugin, 
                          :ret_bool => "false"}, 
      { :method => :post }  ); 
      submenu += super_block(super_submenu);
      
      if (submenu != "") then 
        html = m_sel_item( "Plugin: #{plugin_menu_label(plugin)}" , 
                         :controller =>  :plugins,
                         :action => :show, 
                         :id => plugin); 
        return s_item_html(html + submenu);
      end 
    end 
    # return s_item_html(html); 
    return ""; 
  end
  
  def plugin_menu_label(plugin, len = 15) 
    name = plugin.new_record? ? "Create New" : plugin.name; 
    if (name.length > len) then 
      last_part = plugin.name.gsub(/^.*\./, '')
      pname = (last_part.length > (len - 3)  ? "#{last_part[0..(len-1)]}" : last_part)
      return plugin.content_provider.acronym + " ... " + pname;
    else 
      return plugin.name;
    end
  end
  
  def states_submenu(object, prefix, hash) 
    submenu = ""
    @au_state_params.each do |st| 
      submenu +=  sub_item(object,  prefix + " " +  st.capitalize,  hash.merge({:states => st}))
    end
    return submenu;
  end
  
  def m_sel_item(label, link_hash) 
    return  content_tag('div', link_to(label, link_hash), { :class => "menu"} ) + "\n";
  end
  
  # create div tag with given opts adding "submenu" as a class 
  def s_item_html(html, opts = {}) 
    if (c = opts.delete(:class) || c = opts.delete("class")) then 
      opts = opts.merge(:class => "submenu " + c)
    else 
      opts = opts.merge(:class => "submenu")
    end
    return  content_tag('div', html, opts) + "\n";
  end 
  
  def sub_item(obj, label, link_hash, html_hash = {})
    return "" if (obj.nil? || !obj.allowed_actions.index(link_hash[:action]));
    return "\t" + content_tag('div', link_to(label, link_hash, html_hash), :class => "submenu") + "\n";
  end
    
  def del_item(obj, label, link_hash, del_hash) 
    return "" if (!obj.allowed_actions.index(link_hash[:action]))
    return "\t" + content_tag('div', 
    link_to(label, link_hash, del_hash.merge( :class => "submenu"))) + "\n";
  end
  
end
