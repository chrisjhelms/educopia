class UserSessionsController < ApplicationController
  before_filter  :require_by_all
  
  def before_all
    @allowed_actions = [:go_home]; 
    
    if current_user.nil? then 
      # not logged in 
      @allowed_actions << :new << :create << :new_or_profile;
    else 
      @allowed_actions << :destroy << :new_or_profile
      if (super_user?) then 
        @allowed_actions << :guess_pwd << :new_guess_pwd;
      end
    end 
    return @allowed_actions.index(params['action'].intern) != nil;
  end 
  
  def new
    @user_session = UserSession.new
    render :action => :new, :layout => "login" 
  end
  
  def new_or_profile
    if current_user.nil? then 
      new();
    else 
      redirect_to current_user
    end 
  end
  
  def go_home
    if current_user.nil? then 
      redirect_to archives_url
    else 
      redirect_to collections_mine_url;
    end 
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:notice] = "Login successful!"
      redirect_to collections_mine_url;
    else
      render :action => :new, :layout => "login"
    end
  end
  
  def new_guess_pwd
    @user_session = UserSession.new
    render :action => :new_guess_pwd
  end
  
  def guess_pwd
    @user_session = UserSession.new()
    @pwd = params[:user_session][:password];
    @users = []; 
    for u in User.find(:all) do 
      session = UserSession.new( :login => u.login, :password => @pwd); 
      if (session.valid?) then 
        @users << u; 
      end
    end
  end
  
  def destroy
    current_user_session.destroy
    flash[:notice] = "Logout successful!"
    redirect_to "/"; 
  end
end
