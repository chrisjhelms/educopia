class CollectionsController < ApplicationController
  before_filter  :require_by_all; # calls before_all
  
  def self.allowed_actions(collection, user)
    actions = [:index, :all_or_mine, :find, :search];
    actions << :mine if user  # that is logged in 
    actions << :new << :create  if User.edit?(user) #  and can edit
    if (collection) then  
      actions << :show << :archival_units << :metadata ;
      if (StatusMonitor.active? && user) then 
         actions << :status  
      end
      if (User.obj_edit?(collection, user)) then 
        actions << :edit << :update << :manage_aus; 
        if (collection.empty?) then 
          actions << :destroy 
        else 
          actions << :destroy_aus << :destroy_au << :set_au_states;
        end
        if (collection.can_add_aus) then 
          actions  << :new_au << :create_au << :manage_aus; 
          if (collection.plugin.params_count > 1) then 
             actions << :upload_aus_from_file << :upload_aus;
          end
        end  
      end 
      if (User.super?(user)) then 
        actions << :retire 
      end
      collection.allowed_actions = actions
    end 
    return actions;
  end
  
  
  def before_all
    @state = params[:state] || 'active';   # active, retired or all:: see index  / mine
    @collection = nil;
    if (params['id']) then
      begin
        @collection = Collection.find(params['id']);
      rescue
        raise ActiveRecord::RecordNotFound.new();
      end
    end
    if (@collection) then
      @archival_units = @collection.archival_units;
      @plugin = @collection.plugin;
      @content_provider = @collection.content_provider
    end

    action = params['action'].intern;
    @allowed_actions = CollectionsController.allowed_actions(@collection, current_user)
    @managing_aus = ([:new_au, :upload_aus_from_file, :destroy_aus, :destroy_au,
      :manage_aus, :upload_aus].index(action) != nil);
    params[:managing_aus] = @managing_aus
    flash[:debug] = @plugin.inspect;
    return @allowed_actions.index(action) != nil;
  end
  
  # GET /collections
  # GET /collections.xml
  def index
    @collections = get_collections(@state);
    respond_to do |format| 
      respond_do(format, @collections)
    end 
  end
  
  def mine
    if (!user?) then 
      redirect_to :action => :index;
      return;
    end
    @content_provider = current_user.content_provider;
    @collections = @content_provider.collections(true, @state); 
    respond_to do |format|
      respond_do(format, @collections, :template => '/collections/index'); 
     end
  end
  
  def all_or_mine
    if (@content_provider.nil?) then 
      redirect_to :action => :index;
      return;
    end
    redirect_to :action => :mine;
  end
  
  def metadata
    url = @collection.metadata_url(:show);
    if (url) then 
      logger.info("GET #{url}");
      @xml_metadata = Net::HTTP.get_response(URI.parse(url)).body;
      if (@xml_metadata.nil?) then @xml_metadata = "<error> Could not retrieve #{url} </error>" end
      logger.debug("XML:  " + @xml_metadata);
      respond_to do |format| 
         format.xml  { render :xml => @xml_metadata }
      end   
    end
  end
  
  # GET 
  def find
    name = params['name'].gsub(/_/, ' ')
    redirect_find Collection.find_by_title(name)
  end
  
  # GET /collections/1
  # GET /collections/1.xml
  def show
    init_au_states(:all);
    respond_to do |format| 
      respond_do(format, @collection)
    end 
  end
  
  # get, post
  def search
    cname = params['name'];
    cname =  cname.strip().gsub('%', '\%').gsub('_', '\_')
    quvals = cname.split().collect {|n| "%" + n + "%" }
    if (quvals.empty?) then 
        redirect_to :action => :index 
    else 
	    qu = (1..quvals.size()).collect  { "title like ?" }.join(" and ")
	    @collections = Collection.find(:all,  :conditions=> quvals.insert(0, qu) ) 
	    respond_to do |format| 
	          respond_do(format, @collections, {})
	    end 
    end
  end
      
      
 # GET /collections/new
  def new 
    @archival_units = [];
    @collection = Collection.new()
    @content_provider = current_user.content_provider;
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @collection }
    end
  end
  
  def status 
    @collection_status_items = @collection.collection_status_items;
  end
  
  # POST /collections
  # POST /collections.xml
  def create
    @content_provider = current_user.content_provider;
    params[:collection][:archive] = Archive.find_by_title(params[:collection][:archive])
    params[:collection][:plugin] = @content_provider.placeholder_plugin;
    params[:collection].delete(:plugin_name_other)
    
    @collection = Collection.new(params[:collection])
    
    respond_to do |format|
      if @collection.save
        flash[:notice] = 'Collection was successfully created.'
        format.html { redirect_to :id => @collection.id, :action => :show }
        format.xml  { render :xml => @collection, :status => :created, :location => @collection }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @collection.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # GET /collections/1/edit
  def edit
    
  end
  
  # PUT /collections/1
  # PUT /collections/1.xml
  def update
    params[:collection][:archive] = Archive.find_by_title(params[:collection][:archive])
    params[:collection][:plugin] =  Plugin.find_by_name(params[:collection][:plugin]) || 
                                         @collection.plugin;
    params[:collection].delete(:plugin_name_other)
    params[:collection][:plugin] ||= @collection.plugin;
    params[:collection][:base_url] ||= @collection.base_url; 
    
    respond_to do |format|
      if @collection.update_attributes(params[:collection])
        flash[:notice] = 'Collection was successfully updated.'
        format.html { redirect_to(@collection) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @collection.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # DELETE /collections/1
  # DELETE /collections/1.xml
  def destroy
    @collection.destroy
    
    respond_to do |format|
      format.html { redirect_to(collections_mine_url) }
      format.xml  { head :ok }
    end
  end
  
  # GET
  def manage_aus
    init_au_states(:all);
    @archival_units = @collection.archival_units_filter_by_states(@states)
    respond_to do |format|
        format.html { render :action => "manage_aus" }
        format.xml  { render :xml => :error }
    end
  end
  
  # GET    /collections/new_au(.:format)    
  def new_au 
    init_au_states(:all);
    
    @archival_unit = ArchivalUnit.new(:collection => @collection, 
                                       :param_values => {})
    respond_to do |format|
      if (@plugin.plugin_params.length == 1) then 
        if @archival_unit.save
          flash[:notice] = 'ArchivalUnit was successfully created.'
          format.html { redirect_to collections_manage_aus_url(@collection) }
          format.xml  { render :xml => @archival_unit, :status => :created }
        else
          flash[:error] = 'Could not create ArchivalUnit.'
          format.html { render :action => "new_au" }
          format.xml  { render :xml => @archival_unit.errors, :status => :unprocessable_entity }
        end 
      else
        format.html 
        format.xml  { render :xml => @archival_unit }
      end 
    end  
  end
  
  
  # POST /archival_units.xml
  def create_au
    @archival_unit = ArchivalUnit.new(:collection => @collection, 
                                      :param_values => params['au_param_values'] || {})
    
    respond_to do |format|
      if @archival_unit.save
        flash[:notice] = 'ArchivalUnit was successfully created.'
        format.html { redirect_to :action => :manage_aus, :id => @collection }
        format.xml  { render :xml => @archival_unit, :status => :created, :location => @archival_unit }
      else
        format.html { params['action'] = 'new_au'; render :action => :new_au }
        format.xml  { render :xml => @archival_unit.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # DELETE /collections/au/:id/:au_id 
  def destroy_au
    @archival_unit = ArchivalUnit.find(params[:au_id])
    @archival_unit.assume_super_user= super_user?; 
    @archival_unit.destroy
    
    respond_to do |format|
      format.html { redirect_to :action => :manage_aus, :id => @collection }
      format.xml  { head :ok }
    end
  end
  
  # GET /collections/delete_aus/:au_state
  def destroy_aus
    init_au_states(:none);
    if (@states.empty?) then 
      flash[:error] = 'No such state';
    else 
      @archival_units = @collection.archival_units_filter_by_states(@states); 
      if (@archival_units.empty?) then 
        flash[:error] = "No archival units in state #{@state_name_list}";
      else 
        @archival_units.each {|au| au.destroy }
        flash[:notice] = "Deleted #{@archival_units.length} archival units";
      end
    end
    redirect_to  collections_manage_aus_url(@collection)
  end
  
   # GET /collections/1/manage_aus
  def upload_aus  
     init_au_states(:all);
     render :action => :new_au 
   end
  
  # POST 
  def upload_aus_from_file
    init_au_states(:all)
    begin 
      @file = params[:data_file].path();
    rescue 
      @file = nil; 
    end 
    if (@file.nil?) then
      flash[:error] = "Must choose a CSV File";
    else     
      if (@collection.load_aus_from_csv(@file)) then   
        flash[:notice] = 'ArchivalUnit(s) were successfully uploaded.'
        redirect_to collections_manage_aus_path(@collection) 
        return;
      else
         @collection.errors.add_to_base("Please list correct parameter names in first line of CVS file");          
      end
    end
    render :action => :new_au; 
  end 
  
  # GET /collections/offline_aus/:au_state
  def set_offline_aus
    @state = AuState.find_by_name(params[:au_state]); 
    if (@state.nil?) then 
      flash[:error] = 'No such state';
    else 
      off = (params[:off_state] == "true"); 
      @archival_units = @collection.archival_units_filter_by_states([@state]); 
      ok = true; 
      @archival_units.each {|au| au.off_line = off; ok =  au.save() && ok }
      if (ok)
        flash[:notice] = 'Saved all Availability Settings'
      else
        flash[:error] = 'Could not save .. this reaaly should not happen'
      end 
    end
    
    redirect_to :action => :show
  end
  
  # POST /collections/1/set_au_states
  def set_au_states
    init_au_states(:all)
    errors = [];
    @au_state = params['au_state']; 
    @on_state = params['on_state'] || "site up"; 
    logger.level = Logger::DEBUG; 
    if (!@au_state.nil?) then 
      @archival_units.each { |au| 
        state = @au_state["#{au.id}"]
        off_line = (@on_state["#{au.id}"] == "site down")
        logger.debug("AU_STATE #{au.id} #{au.off_line}")
        if (!state.nil?) then 
          au.assume_super_user= super_user?; 
          au.au_state = AuState.get(state); 
        end 
        au.off_line = off_line; 
        if (!au.save) then 
            errors << (au.errors["base"]) 
        end
      }
      if (errors.empty?)
        flash[:notice] = 'Saved all Archival Unit States'
      else
        @collection.errors.add_to_base('Did not save archival unit states'); 
        errors.uniq.each { |e| @collection.errors.add_to_base("Archival Unit: " + e.to_s) } 
      end 
    end 
    
    @managing_aus = true;
    render :action => :manage_aus;  
  end
  
  def status 
    @status_items = @collection.collection_status_items;
  end
  
  def retire 
    init_au_states(:all)
    @retire = (params['ret_bool'] == "true");
    @collection.retired = @retire; 
    if (!@collection.save) then 
      @collection.reload;
    end
    render :action => :show;
  end

 private 
 def get_collections(state) 
   if (state == "all") then 
     return Collection.find(:all, :order => 'title')
   elsif (state == "active") then 
     return Collection.find(:all,  :conditions => { :retired => false }, :order => 'title')
   else # state == "retired" 
     return Collection.find(:all,  :conditions => { :retired => true }, :order => 'title')
   end   
 end

end
