module LeftRightHelper  # TODO Generated stub
  def left_right_html(left, right) 
    return  "<table class='headline_table'>\n" + 
                  "<tr><td>" + left + "</td>\n" + 
                  "<td align='right'>" + right  + "</td></tr></table>\n";
  end
  
  def left_right_title(title, right) 
    return left_right_html("<h2> #{title} </h2>", "<h3> #{right} </h3>")
  end
  
end