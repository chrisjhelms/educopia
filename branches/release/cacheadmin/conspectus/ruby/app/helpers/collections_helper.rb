# Methods added to this helper will be available to all templates in the application.
module CollectionsHelper
  
  def collection_cp_archive(col)  
    if (col.new_record?) then 
      return "";
    end
    return col.content_provider.acronym + " / " + col.archive.title; 
  end 
  
  def collection_icon_title(col) 
    return content_provider_image_tag(col.content_provider) + " " + link_to(col.title, col); 
  end
  
  def collection_list_title(mine) 
    my  = (mine) ? " My " :  "All "; 
    return   title = my + "Collections"
   end 
  
end