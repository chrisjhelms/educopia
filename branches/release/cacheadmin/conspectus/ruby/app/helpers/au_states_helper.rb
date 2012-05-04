# Methods added to this helper will be available to all templates in the application.
module AuStatesHelper
  
  def au_states_select(name, reversibles_only, sel_state)
    allowed_states = AuState.getStates(reversibles_only); 
    if (reversibles_only) then 
      allowed_states = allowed_states.select { |st| !st.irreversible? }
    end
    return select_one(name, allowed_states, :name, sel_state, false)
  end
  
  def au_states_list_names(names, prefix =  "") 
    if names.empty? then 
      return ""; 
    else 
      return " " + prefix  + " " + names.collect{ |n| n.capitalize}.join(", ");
    end
  end

end
