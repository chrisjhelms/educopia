# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all
  helper_method :current_user_session, :current_user
  filter_parameter_logging :password, :password_confirmation
  
  #rescue_from ErrorNotFound, :with => :report_error
  
  def init() 
    flash.delete(:error_detail);
    super.init(); 
  end
  
  def require_by_all  
    #raise "where from"
    allow = false; 
    begin 
      allow = before_all
      logger.info("require_by_all allowed_actions #{@allowed_actions.inspect}") 
    rescue  ActiveRecord::RecordNotFound => e
       respond_to do |format|
        format.html { render :partial => "/errors/e404", :layout => "error", :status => 404 }
        format.xml { render :status => 404 }
      end
      return false;
    end 
    if (!allow) then  
      respond_to do |format|
        format.html { render :partial => "/errors/e401", :layout => "error", :status => 401 }
        format.xml { render :status => 401 }
      end
      return false;
    end
    return allow;
  end
  
  def rescue_action_in_public(e) 
     deal_with_error(e) 
  end 
  
  def rescue_action_locally(e) 
     deal_with_error(e) 
  end 
  
  def deal_with_error(e) 
    # raise e ;
    do_error = Global.get("show_params") == "true"
    status = 400; 
    if e.instance_of?(ActiveRecord::RecordNotFound) then 
          status = 404
    elsif e.instance_of?(RuntimeError) then 
          status =  500
    end  
    @error_detail = nil;
    if (do_error) then 
      @error_detail = e.backtrace.join("<br/>") 
    end 

    respond_to do |format|
      format.html { render :partial => "/errors/e#{status}", :layout => "error", :status => status }
      format.xml  { render :xml => "<error> #{e.message} </error>", :status => status  }
    end
  end
  
  protected 
  
  def respond_do(fmt, obj, html_args = {}, action = params["action"])  
    fmt.html { if (html_args.empty?) then render action  else render action, html_args end }
    fmt.json { render :json=>obj }
    fmt.xml { render :xml=>obj }
  end
  
  def redirect_find(obj) 
    controller = params["controller"];
    if (obj) then
      url = "/#{controller}/#{obj.id}"
      more = params['rest'].join("/");
      url = url + "/" + more
      redirect_to url
    else
      redirect_to "/#{controller}";
    end
  end
  
  def show_html
    respond_to do |format|
      format.html { } 
      end
  end

  def super_user? 
    return current_user != nil && current_user.rights == "super";
  end
  
  def edit_user?
    return current_user != nil && current_user.rights != "view";
  end
  
  def  user?
    return current_user != nil; 
  end
  
  def self.check_obj_edit_user?(obj, user)
    return false if user.nil? || obj.nil?; 
    return true if user.rights == "super";
    begin 
      return user.rights == "edit" && obj.content_provider == user.content_provider
    rescue
      return false 
    end   
  end      
  
  def obj_edit_user?(obj) 
    return ApplicationController.check_obj_edit_user?(obj, current_user); 
  end
  
  private
  def current_user_session
    begin
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    rescue
      return nil;
    end
  end
  
  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
  end
  
  def require_user(rights = "")
    unless current_user
      store_location
      flash[:notice] = "You must be logged in to access this page"
      redirect_to new_user_session_url
      return false
    end
    unless rights.empty? or current_user.rights == "super" or current_user.rights == rights
      store_location
      flash[:error] = "You do not have access rights"
      redirect_to :back;
      return false
    end
    return true;
  end
  
  def require_no_user
    if current_user
      store_location
      flash[:notice] = "You must be logged out to access this page"
      redirect_to account_url
      return false
    end
    return true;
  end
  
  def store_location
    session[:return_to] = request.request_uri
  end
  
  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
  
  # return states corresponding to states parameter
  # if there is no such parameter return All States  or [] 
  def init_au_states(all_or_none)
    @state_name_list = [];
    @states =  params['states']
    if (@states.nil?) then  
      if (all_or_none == :all) then 
        @states = AuState.find(:all);
      else 
        @states = []; 
      end
    else 
      @states = AuState.getList(params['states']); 
      @state_name_list = @states.collect { |s| s.name }
    end
  end

end
