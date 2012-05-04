module UserSessionsHelper
   def authentication_info() 
    if (current_user_session) then 
      provider = ""; 
      provider = "#{content_provider_image_tag(current_user.content_provider)}" if (current_user.content_provider); 
      rights = ""; 
      rights = content_tag(:span, "[SUPERUSER]")  if (current_user.rights == "super")
      return  link_to("My Profile", current_user) + 
              " | "  + 
              content_tag(:span, link_to("Logout", {:controller => :user_sessions, 
                                                     :action => :destroy}, :method => :delete)) +
             "<br/> #{provider} Welcome #{current_user.login} #{rights}";
    else 
      return link_to("Login", new_user_session_url);
    end
  end

   def is_super_user 
     return current_user != nil && current_user.rights == "super";
   end
  end
