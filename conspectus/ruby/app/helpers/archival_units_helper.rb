# Methods added to this helper will be available to all templates in the application.
module ArchivalUnitsHelper

  def archival_unit_delete_link(inst)
    if inst.deletable?(is_super_user)  then 
          return link_to('Delete', 
                          destroy_au_collections_url(inst.collection, inst), 
                                                            :method => :delete, 
                                                            :confirm => "Are you sure ?" ); 
        else 
          if (inst.has_status?) then 
            return archival_unit_preservation_status_link(inst, "replicated")
          else 
            return "&nbsp;"; 
          end 
        end
  end
  
  def archival_unit_preservation_status_link(inst, label = nil)
    label = label || inst.au_state.name
    return link_to(label, view_status_au_collections_url(inst.collection, inst))
  end

  def archival_unit_preservation_status_edit(inst)
    irreversible = inst.au_state.irreversible?
    if (is_super_user || !irreversible) then 
      allowed_states = AuState.getStates(!is_super_user); 
      return au_states_select("au_state[#{inst.id}]",  !is_super_user, inst.au_state); 
    else 
      return archival_unit_preservation_status_link(inst);
    end
  end 
  
  def archival_unit_off_line(inst)
    return inst.off_line ? "site down" : link_to_ext("site up", inst.collection.base_url)
  end 
  
  def archival_unit_off_line_edit(inst)
    irreversible = inst.au_state.irreversible?
    if (irreversible || inst.off_line) then 
        return select_tag("on_state[#{inst.id}]",  
                            "<option #{inst.off_line ? " selected" : ""}> site  down </option>" +  
                            "<option #{inst.off_line ? "" : " selected"}> site up</option>");
      # row += "\n\t\t" + select_one("au_state[#{inst.id}]", ["true", "false"], :off_line, inst.off_line, false)                           
    else
      return archival_unit_off_line(inst)
    end
  end
  
  def archival_unit_param_table(inst, show_base_url)
    values = inst.au_param_values   
    if (show_base_url) then
      values['base_url'] = link_to_ext(inst.collection.base_url, inst.collection.base_url) 
    end
    html = ""; 
    if (values.empty?) then
      html =  "One AU Defined By Base_Url"; 
    else 
      values.keys.sort.each { |n| 
        html +=  "<br/>" +  n + " = " + values[n]; 
      }; 
      html = html.sub(/^<br.>/, '');
    end 
    return html;
  end
  
  def archival_unit_param_form(values_array, params)
    if (params.key?(values_array)) then                  
      values = params[values_array];             
    else                 
      values = {}                
    end                  
    form = form_tag(:action => :create_au, :id => @collection)                   
    
    for pn in @archival_unit.au_param_names.sort do              
      form += content_tag('tr',                  
      content_tag('td', content_tag('label', pn)) + " " +                   
      content_tag('td', text_field(values_array, pn, { "value" => values[pn] }))) + "\n";                   
    end                  
    form = error_messages_for('archival_unit') + content_tag('table', form);             
    
    form += submit_tag "Add ArchivalUnit"                
    form += "</form>";                   
    return form;                 
  end 

  
end
