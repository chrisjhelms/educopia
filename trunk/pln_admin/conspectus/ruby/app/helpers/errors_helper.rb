module  ErrorsHelper
  def errors_for_obj(obj)
    msgs = obj.errors.full_messages
    
    return "" if (msgs.length == 0)
    
    error_list = "";
    msgs.each do |msg|
      error_list = error_list + content_tag(:li, msg);
    end

    return content_tag(:div, content_tag(:ul, error_list),
                        :class =>   "errorExplanation", :id => "errorExplanation")
  end

end
