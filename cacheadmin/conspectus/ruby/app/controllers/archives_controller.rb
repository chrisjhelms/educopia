# Archives can be viewed by all but should be edited  only by authorized users.
# For extra protection creation and deletion is not allowed via GUI.

class ArchivesController < ApplicationController
  before_filter  :require_by_all; # calls before_all
  
  def self.allowed_actions(obj, user)
    actions = [:index, :find];
    if (User.super?(user)) then 
      actions << :new << :create << :destroy;
    end 
    if (obj) then  
      actions << :show << :archival_units << :plugins
      if (User.super?(user)) then 
        actions << :edit << :update << :configure;
      end
      if (user) then 
        actions << :status;
      end
      obj.allowed_actions = actions;
    end 
    return actions
  end
  
  def before_all() 
    @state = params[:state] || 'active';
    @archive = nil; 
    if (params['id']) then
      begin
        @archive = Archive.find(params['id']);
      rescue
        raise ActiveRecord::RecordNotFound.new();
      end
    end
    @allowed_actions = ArchivesController.allowed_actions(@archive, current_user)
    return @allowed_actions.index(params['action'].intern) != nil; 
  end

  # GET 
  def index
    @archives = Archive.find(:all, :order => "title")
    respond_to do |format|
      format.html # list.html.erb
      format.xml  { render :xml => @archives }
    end
  end 
  
  # GET=
  def find
    redirect_find(Archive.find_by_title(params[:name]));
  end
    
  # GET=
  def show
    @collections = @archive.collections(true, @state) 
    respond_to do |format| 
      respond_do(format, @archive)
    end  
  end
  
  # show-all archival units in archive's collections
  # GET 
  def archival_units
    init_au_states(:all)
    # @collections = @archive.collections_filter_by_states(@states); 
    @archival_units = @archive.archival_units_filter_by_states(@states); 
    respond_to do |format|
      format.html { @archival_units = @archival_units}   
      format.json { render :json=> @archival_units }
      format.xml  { render :xml => ArchivalUnit.to_xml(:au_list => @archival_units, :skip_instruct => true) }
    end
  end
  
  # show-all plugins in archive's collections
  # GET 
  def plugins
    @plugins = @archive.plugins(true, @state); 
    respond_to do |format|
      format.html  { @plugins }
    end
  end

  # GET /archivess/new
    def new 
      @archive = Archive.new()
      respond_to do |format|
        format.html { render  :action => :edit } # new.html.erb
        format.xml  { render :xml => @archive }
      end
    end
    
    
    # POST /archives
    # POST /archives.xml
    def create
      @archive= Archive.new(params[:archive])
      
      respond_to do |format|
        if @archive.save
          flash[:notice] = 'Archive was successfully created.'
          format.html { redirect_to :id => @archive.id, :action => :show }
          format.xml  { render :xml => @archive, :status => :created, :location => @collection }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @archive.errors, :status => :unprocessable_entity }
        end
      end
    end
    
    # GET 
  def edit
  end
  
  # PUT 
  def update
    respond_to do |format|
      if @archive.update_attributes(params[:archive])
        flash[:notice] = 'Archive was successfully updated.'
        format.html { redirect_to(@archive) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @archive.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # DELETE /archives/1
  # DELETE /archives/1.xml
  def destroy
    respond_to do |format|
      begin
        @archive.destroy
        format.html { redirect_to(archives_url) }
        format.xml  { head :ok }
      rescue Exception => e
        format.html { @collections = @archive.collections ; 
                      @archive.errors.add_to_base(e.message);
                      render :action => "show" }
        format.xml  { render :xml => @archive.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def status 
    @archive_status_items = @archive.archive_status_items;
  end
end
