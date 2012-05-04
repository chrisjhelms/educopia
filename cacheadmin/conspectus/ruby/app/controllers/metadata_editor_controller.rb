class MetadataEditorController < ApplicationController
  def header
  end

  def footer
    render :action => "footer", :layout => "metadata_editor_footer"
  end

end
