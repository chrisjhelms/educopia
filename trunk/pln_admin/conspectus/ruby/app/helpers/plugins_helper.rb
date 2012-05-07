# Methods added to this helper will be available to all templates in the application.
module PluginsHelper

  def plugin_display_name(p, c = nil)
    name = p.display_name;
    if  (!c.nil?) then
      name = name[c.plugin_prefix.length, 100]
    end
    return name;
  end  
  
  def plugin_display_name_link(p, c = nil)
    return link_to(plugin_display_name(p, c), p);
  end
  
  def plugin_source_link(p, mode, label)
     lnk = p.xml_url(mode)
     if (lnk != "") then
       return  link_to_ext(label, lnk); 
     else
       return "";
      end
  end
  
  def plugin_xml_source_info(p)
    if (p.retired) then 
      s1 = plugin_source_link(p, "retired_plugin_url", "retired");
      if (s1 != "") then 
         return s1;
      end
    else 
     s1 = plugin_source_link(p, "production_plugin_url", "production"); 
     s2 = plugin_source_link(p, "test_plugin_url", "test") 
     if (s1 != "") then
         return s1 + "&nbsp; &nbsp;" + s2; 
     end  
    end
    return "xml source unknown" 
  end

end
