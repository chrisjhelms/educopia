class PluginsController < ApplicationController
  before_filter  :require_by_all; # calls before_all
  
  def self.allowed_actions(plugin, user)
    actions = [:index, :all_or_mine, :find];
    actions << :mine if user  # that is logged in 
    actions << :new << :create  if User.edit?(user) 
    if (plugin) then  
      actions << :show << :archival_units;  
      if (User.obj_edit?(plugin, user) && plugin.may_edit) then
        actions << :edit << :update << :new_param << :create_param << :destroy_param
        if (plugin.may_delete) then
          actions << :destroy;
        end
        if (user.super?) then 
          actions << :retire
        end
      end
      plugin.allowed_actions = actions;
    end
    return actions
  end
  
  
  def before_all
    @state = params[:state] || 'active';
    if (params['id']) then
      begin
        @plugin = Plugin.find(params['id']);
      rescue
        raise ActiveRecord::RecordNotFound.new();
      end
    end
    @allowed_actions = PluginsController.allowed_actions(@plugin, current_user)
    return @allowed_actions.index(params['action'].intern) != nil;
  end

  # GET /plugins
  # GET /plugins.xml
  def index
    @plugins = get_plugins(@state); 
    respond_to do |format|
      format.html 
      format.xml  { render :xml => @plugins }
    end
  end

  def mine
    if (!user?) then 
      redirect_to :action => :index;
      return;
    end
    @content_provider = current_user.content_provider;
    @plugins = current_user.content_provider.plugins(true,@state).select{ |p| !p.placeholder?}; 
    respond_to do |format|
      format.html { render :template => 'plugins/index' }
      format.xml  { render :xml => @plugins }
    end
  end

  def all_or_mine
    if (current_user.nil? || current_user.content_provider.nil?) then 
      redirect_to :action => :index;
      return;
    end
    redirect_to :action => :mine;
  end
  
  def find 
    name = params['name'].gsub(/\|/, '.')
    redirect_find Plugin.find_by_name(name)
  end
  
  # GET /plugins/1
  def show
    @plugin_params = @plugin.plugin_params 
    @collections = @plugin.collections
    respond_to do |format| 
      respond_do(format, @plugin)
    end 
  end

  # GET /plugins/archival_units/1
  # GET /pluginss/archival_units/1.xml
  def archival_units
    init_au_states(:all);
    @plugin_params = @plugin.plugin_params 
    @archival_units= @plugin.archival_units_filter_by_states(@states);
    init_au_states(:all);
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json=> @archival_units }
      format.xml  { render :xml => ArchivalUnit.to_xml(:au_list => @archival_units, :skip_instruct => true) }
    end
  end
  
  # GET /plugins/new
  # GET /plugins/new.xml
  def new
    @content_provider = current_user.content_provider;
    @plugin = Plugin.new(:content_provider => @content_provider)
    logger.info("#{@plugin.errors.full_messages.inspect}")   
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @plugin }
    end
  end

  # GET /plugins/1/edit
  def edit
    @plugin_params = @plugin.plugin_params
    @plugin_param = PluginParam.new(:plugin => @plugin); 
  end

  # POST /plugins
  # POST /plugins.xml
  def create
    @content_provider = current_user.content_provider; 
    params[:plugin][:content_provider] = @content_provider
    name = @content_provider.plugin_prefix + "." + params[:plugin][:name];
    if (@plugin = Plugin.find_by_name(name)) then 
      flash[:error] = "Duplicate Plugin Name";
      logger.info("#{@plugin.errors.full_messages.inspect}")   
      redirect_to(:id => @plugin, :action => :show)   #May not be able to edit so redirect to show
      return;
    end 
    @plugin = Plugin.create(name, params[:plugin][:content_provider])
    respond_to do |format|
      if @plugin.errors.empty?
        format.html { redirect_to(:id => @plugin, :action => :show) }
        format.xml  { render :xml => @plugin, :status => :created, :location => @plugin }
      else
        logger.info("#{@plugin.errors.full_messages.inspect}")   
        format.html { @plugin.name = params[:plugin][:name]; render :action => :new } 
        format.xml  { render :xml => @plugin.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /plugins/1
  # PUT /plugins/1.xml
  def update
     respond_to do |format|
      if @plugin.update_attributes(params[:plugin])
        flash[:notice] = 'Plugin was successfully updated.'
        format.html { redirect_to(@plugin) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @plugin.errors, :status => :unprocessable_entity }
      end
    end
  end


  # DELETE /content_providers/1
  # DELETE /content_providers/1.xml
  def destroy
     respond_to do |format|    
      begin 
        @plugin.destroy
        format.html { redirect_to( plugins_mine_url )}
        format.xml  { head :ok }
      rescue
        flash[:error] = "Can't destroy"
        format.html { redirect_to :action => "show" } 
        format.xml  { render :xml => @plugin.errors, :status => :unprocessable_entity }
      end  
    end
  end
  
  def retire 
    @retire = (params['ret_bool'] == "true");
    @plugin.retired = @retire; 
    if (!@plugin.save) then 
      @plugin.reload;
    end
    @plugin_params = @plugin.plugin_params 
    @collections = @plugin.collections;
    render :action => :show;
  end
  
 private 
 def get_plugins(state) 
   conds  = ['name NOT LIKE ? ', '%.NONE%']
   if (state == "all") then 
     plugins = Plugin.find(:all, :conditions => ["name NOT LIKE ?",'%.NONE%']);
   else 
     plugins = Plugin.find(:all, :conditions => ["name NOT LIKE ? AND retired = ?", 
                                                 '%.NONE%', 
                                                 (@state == 'retired') ? 1 : 0]);
   end
   return plugins;
 end
end
