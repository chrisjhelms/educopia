class PluginParamsController < ApplicationController
  before_filter  :require_by_all; # calls before_all
  
  def before_all 
    @plugins = nil; 
    @allowed_actions = [];
    if params.key?("plugin_id")
       @plugin = Plugin.find(params["plugin_id"])
       @plugin_params= @plugin.plugin_params
    end
    if (@plugin && User.obj_edit?(@plugin, current_user) && @plugin.may_edit) then
       @allowed_actions = [:create, :update, :destroy];
    end
  
    #params[:allowed_actions] = @allowed_actions;
    return @allowed_actions.index(params['action'].intern) != nil;
  end


  # POST
  def create
    params[:plugin_param]['plugin_id'] = @plugin.id; 
     
    @plugin_param = PluginParam.new(params[:plugin_param])

    respond_to do |format|
      if @plugin_param.save
        flash[:notice] = 'PluginParam was successfully created.'
        format.html { redirect_to(:id => @plugin, :controller => :plugins, :action => :edit) }
        format.xml  { render :xml => @plugin_param, :status => :created, :location => @plugin_param }
      else
        format.html { render :template => "/plugins/edit" }
        format.xml  { render :xml => @plugin_param.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT 
 def update
    @plugin_param = PluginParam.find(params[:id])

    respond_to do |format|
      if @plugin_param.update_attributes(params[:plugin_param])
        format.html { redirect_to(:id => @plugin, :controller => :plugins, :action => :edit) }
        format.xml  { head :ok }
      else
        format.html { render :template => "/plugins/edit" }
        format.xml  { render :xml => @plugin_param.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE 
  def destroy
    @plugin_param = PluginParam.find(params[:id])
    @plugin_param.destroy

    respond_to do |format|
      format.html { redirect_to(:id => @plugin.id, :controller => :plugins, :action => :edit) }
      format.xml  { head :ok }
    end
  end
end
