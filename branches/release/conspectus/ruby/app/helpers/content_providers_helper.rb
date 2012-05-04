# Methods added to this helper will be available to all templates in the application.
module ContentProvidersHelper
  
  def content_provider_delete_link(cp) 
    if (is_super_user) then
      return link_to('delete',  
                     { :controller => :content_providers, 
                       :action => :destroy, 
                       :id => cp}, 
                 :method => :delete, 
                 :confirm => "Are you sure ?");
    else
      return ""; 
    end 
  end 
  
  def content_provider_image_tag(cp) 
    return image_tag(cp.icon_url, :class => "favicon", :alt => cp.acronym) 
  end
  
end
