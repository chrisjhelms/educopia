# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def spacer_image(opts = {:border => "0"})
    return tag(:img, {:src => "/images/spacer.gif", :alt => ""}.merge(opts))
  end
  
  def select_obj_options(objs, method, selected, sort) 
    raise "objs empty" if objs.empty?
    string = "";
    if (sort) then 
      sorted =  objs.sort! { |a,b|  a.send(method) <=>  b.send(method)  } 
      objs = sorted; 
    end 
    objs.each { |o|
      string += "<option "
      if (o == selected) then 
        string += "selected ";
      end
      string += "> " + o.send(method); 
      string += "</option>\n";
    }
    return string;
  end
  
  def select_str_options(strs, selected) 
    raise "strs empty" if strs.empty?
    string = "";
    sorted =  strs.sort!  { |a,b| a <=> b  }
    sorted.each { |o|
      string += "<option "
      if (o == selected) then 
        string += "selected ";
      end
      string += "> " + o; 
      string += "</option>\n";
    }
    return string;
  end
  
  def select_one(name, objs, method, selected = nil, sort = true)
    return select_tag(name, select_obj_options(objs, method, selected, sort))
  end 
  
  def select_one_or_other(name, objs, method, selected = nil, sort = true)
    opts = "<option>Other</option>\n"
    return select_tag(name, opts + select_obj_options(objs, method, selected, sort))
  end 
  
  def link_short(str, obj, len = 40)
    str ||= ''
    shorten = (str.length > len)
    if (shorten) then 
      shortvalue = (shorten ? "#{str[0..(len-1)]}..." : str)
      str = str.gsub(/"/, "'"); 
      return "<span title=\"#{str}\"> " + link_to(shortvalue, obj) + "</span>"
    else
      return "<span> " + link_to(str, obj) + "</span>"
    end
  end
  
  def span_short(str, len = 40)
    str ||= ''
    shorten = (str.length > len)
    if (shorten) then 
      shortvalue = (shorten ? "#{str[0..(len-1)]}..." : str)
      return "<span title=\'#{str}\'> " + shortvalue + "</span>"
    else
      return "<span> " + str + "</span>"
    end
  end
  
  
  def instance_table_start(headers, cls = "instance_table tablesorter")
    str = "\n<table class=\'#{cls}\'>"; 
    if (!headers.nil? && !headers.empty?) then 
      th = ""; 
      headers.each { |h| th = th + content_tag(:th, h) } 
      str = str + content_tag(:thead, content_tag(:tr, th));  
      str =  str + "<tbody>"
    end 
    return str; 
  end
  
  def instance_table_stop()
    return "</tbody></table>\n"; 
  end
  
  def link_to_ext(name, url, opts = {})
    # name = name.sub(/^[a-zA-Z]+:\/\//, '') 
    return link_to(name + " " + image_tag("external.png"), url, {:target => "_blank"}.merge(opts))
  end
  
  def links_to_retired_state_listers(path) 
    lnks  = ((@state == 'active') ?  "Excluding Retired" :  link_to('Exclude Retired', "#{path}/state/active") ); 
    lnks += " | "; 
    lnks += ((@state == 'all') ?  "Including Retired" : link_to('Include Retired', "#{path}/state/all") ); 
    lnks += " | "; 
    lnks += ((@state == 'retired') ?  "Retired Only" : link_to('Retired Only', "#{path}/state/retired")); 
    return lnks;
  end 
  
  def links_to_au_state_listers
    return content_tag("span", "Archival Units", :id => 'au_list_title'); 
  end 
  
  def super_block(html) 
    if (html != "") then 
      return content_tag(:div, html, :class => "super");
    end
    return html;
  end
  
end
