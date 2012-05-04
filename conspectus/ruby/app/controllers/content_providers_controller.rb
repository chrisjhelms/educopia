class ContentProvidersController < ApplicationController
  before_filter  :require_by_all; # calls before_all
  
  def self.allowed_actions(obj, user)
    actions = [:index, :find, :search]; 
    if (obj) then  
      actions << :show << :archival_units << :plugins;
      if (user) then 
        actions << :status;
        if (User.super?(user)) then 
          actions << :edit << :update;
          actions << :destroy if obj.may_destroy?
        end
      end
    end 
    if (User.super?(user)) then 
      actions << :new << :create;
    end
    if (obj) then 
      obj.allowed_actions = actions;
    end
    return actions;
  end
  
  def before_all()
    @state = params[:state] || 'active';   # active, retired or all collections:: see index  / mine

    @content_provider = nil;
    if (params['id']) then
      begin
        @content_provider = ContentProvider.find(params['id']);
      rescue
        raise ActiveRecord::RecordNotFound.new();
      end
    end
    @allowed_actions = ContentProvidersController.allowed_actions(@content_provider, current_user)
    return @allowed_actions.index(params['action'].intern) != nil;
  end

  # GET /content_providers
  # GET /content_providers.xml
  def index
     @content_providers = ContentProvider.find(:all, :order => "name")
     respond_to do |format|
       format.html # list.html.erb
       format.xml { render :layout => 'none' }
       format.json { render :json=>  @content_providers }
     end
  end 

  def find
    acro = params['name']; 
    redirect_find ContentProvider.find_by_acronym(acro);
  end

  # GET /content_providers/1
  # GET /content_providers/1.xml
  def show
    @collections = @content_provider.collections(true, @state) 
    respond_to do |format| 
      respond_do(format, @content_provider)
    end 
  end
  
  # post
  def search
    @search_name = params['name']
	@search_name = @search_name.strip();
    @search_name =  @search_name.strip().gsub('%', '\%').gsub('_', '\_')
    quvals = @search_name.split().collect {|n| "%" + n + "%" }
    
    if (quvals.empty?) then 
        redirect_to :action => :index 
    else 
	    qu = " name like ? or acronym like ? OR plugin_prefix like  ? "
	    if (quvals.size() > 1) then
	      qu = (1..quvals.size()).collect  { "(" + qu + ")" } .join( " and ")
	    end
	    quvals = quvals.collect { |v| [v,v,v] } .flatten()
	    @content_providers = ContentProvider.find(:all,  :conditions=> quvals.insert(0, qu) ) 
	    respond_to do |format|        
	      respond_do(format, @content_providers, {}, "index")
	    end 
	end
	
   end

  # GET /content_providers/plugins/1
  # GET /content_providers/plugins/1.xml
  def plugins
    @plugins = @content_provider.plugins(true, @state).select { |p| !p.placeholder?() }
    respond_to do |format|
      format.html  { @plugins }
      format.xml  { render :xml => @content_provider }
    end
  end
  
  # GET /content_providers/archival_units/1
  # GET /content_providers/archival_units/1.xml
  def archival_units
    init_au_states(:all);
    @archival_units =  @content_provider.archival_units_filter_by_states(@states)
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json=> @archival_units }
      format.xml  { render :xml => ArchivalUnit.to_xml(:au_list => @archival_units, :skip_instruct => true) }
    end
  end

  def status 
    @status_items = @content_provider.content_provider_status_items;
  end
 
 
  def new
    @content_provider = ContentProvider.new
    @content_provider.icon_url = "http://www.metaarchive.org/favicon.ico";
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @collection }
    end
  end
  
  def create
    @content_provider = ContentProvider.new(params[:content_provider])
   if @content_provider.save then 
        flash[:notice] = "ContentProvider created!"
        redirect_to :controller => :content_providers, :action => "index"; 
    else
        render :action => "new" 
    end
  end
  
  # DELETE /collections/1
  # DELETE /collections/1.xml
  def destroy
    @content_provider.destroy

    respond_to do |format|
      format.html { redirect_to(content_providers_url) }
      format.xml  { head :ok }
    end
  end
    
  # GET /content_providers/1/edit
  def edit
  end

  # PUT /content_providers/1
  # PUT /content_providers/1.xml
  def update
    respond_to do |format|
      if @content_provider.update_attributes(params[:content_provider])
        flash[:notice] = 'ContentProvider was successfully updated.'
        format.html { redirect_to(@content_provider) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @content_provider.errors, :status => :unprocessable_entity }
      end
    end
  end

end
