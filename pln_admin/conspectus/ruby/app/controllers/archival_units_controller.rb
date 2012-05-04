class ArchivalUnitsController < ApplicationController
  before_filter  :require_by_all; # calls before_all
  
  def before_all
    @allowed_actions = [];
    
    if (params[:au_id]) then 
      @archival_unit = ArchivalUnit.find(params['au_id'])
    end
    if (!params[:id]) then 
      params[:id] =  @archival_unit.collection.id unless @archival_unit.nil? 
    end
    if (params['id']) then 
      @collection = Collection.find(params['id']); 
      if ((@collection.nil?) || (@archival_unit.nil?) || 
       (@archival_unit.collection != @collection)) then 
        raise ActiveRecord::RecordNotFound.new();
      end
      if (@archival_unit) then 
        @allowed_actions << :show
        if (user?) then 
          @allowed_actions << :status;
        end
      end 
    end 
    if (super_user?) then 
      @allowed_actions << :update_status
    end
    if (true || super_user?) then 
      # will replace when script on admin server learns to login or 
      # will replace with privileged IP access rights 
      @allowed_actions << :index;
      @allowed_actions << :search;
      if (!defined? @archival_unit) then 
        @allowed_actions << :get_lockss_au_ids << :update_lockss_au_ids << :update_lockss_au_ids_from_url;
      end
    end
    
    #params[:allowed_actions] = @allowed_actions;
    return @allowed_actions.index(params['action'].intern) != nil;
  end  
  
  
  # show-all archival units in one of the given states 
  def index
      init_au_states(:all);
      @archival_units = ArchivalUnit.find_by_states(@states); 
      respond_to do |format|
        format.html {}
        format.xml  { render :xml =>  ArchivalUnit.to_xml(:au_list => @archival_units, :skip_instruct => true) }
      end
   end
  
  def show 
    @archival_unit.reload; 
    if (User.obj_edit?(@archival_unit, current_user)) then 
      @preservation_status_items = @archival_unit.preservation_status_items;
    end
    respond_to do |format|
      format.html 
      format.xml  { render :xml =>  @archival_unit } 
      format.json  { render :json =>  @archival_unit } 
    end
  end

  # get, post
  def search
    auid = params['name'];
    if (auid) then
      # auid = CGI.escape(auid) if auid
      au = ArchivalUnit.find_by_lockss_au_id(auid.strip());
      if (au) then
	     redirect_to :action => "show", :au_id => au
       return
      end
	   end
     render :partial => "/application/search", :layout => "application"
  end

  def status
    redirect_to :action => :show;  
  end

  def  update_status
    logger.info("update_status #{@archival_unit.id}") 
    repl = PreservationStatusItem.update_archival_unit(@archival_unit, logger, StatusMonitor.au_status_url )
    redirect_to :action => :show
  end
  
  def  get_lockss_au_ids
    lockss_au_ids(params[:ids])
    respond_to do |format|
      format.html { render :action => :lockssauids }    
    end
  end
  
  def update_lockss_au_ids
    lockss_au_ids(params[:ids]) 
    @results = LockssAu.attach_to_archival_units(@lockssauids); 
    logger.info("results #{@results.inspect}") 
    respond_to do |format|
      format.html { render :action => :lockssauids}    
      format.xml  { render :xml => @results}
      format.json  { render :json => @results }
    end
  end

  # POST
  def update_lockss_au_ids_from_url
    @remote_url = params['url'];  
    @data = NetData.new(@remote_url, "get") 
    status = 200;
    begin 
      @lockssauids = @data.convert(LockssAu) || []
      status = @data.status
    rescue
      @lockssauids = []
      status = 500
    end
    logger.info("@remote_url ==> data #{@data.inspect} #{@data.status}") 
    LockssAu.attach_to_archival_units(@lockssauids); 
    
    respond_to do |format|
      format.html { render :action => :lockssauids}    
      format.xml  { render :xml => @results, :status => @data.status }
      format.json  { render :json => @results, :status => @data.status }
    end
  end
  private
  
  def lockss_au_ids(auids)
    ids = auids || '';
    @remote_url = StatusMonitor.auid_list_url
    @lockssauids = []; 
    if (ids.class == String) then
      ids.each_line { |s| ss=  s.strip;  @lockssauids << LockssAu.new(ss) unless ss.empty? } 
    else
      @lockssauids = ids;
    end
    @results = [];
    logger.info("lockssauids #{@lockssauids.inspect}");
  end
end
