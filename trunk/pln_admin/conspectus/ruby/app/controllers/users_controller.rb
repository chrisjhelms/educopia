class UsersController < ApplicationController
  #before_filter :require_no_user, :only => [:new, :create]
  before_filter  :require_by_all; # calls before_all
  
  def before_all
    @page = params[:page] || 1
    @allowed_actions = [];
    if (require_user) then 
      @allowed_actions << :show << :edit <<:update;
      @user = current_user
      if (super_user?) then 
        @allowed_actions << :index << :find << :new << :create << :edit_user << :destroy << :guess_pwd;
        if (params['id']) then 
          @user = User.find(params[:id]);
        end 
      end
    params['user_id'] = @user.id;
    end 
    #params[:allowed_actions] = @allowed_actions;
    return @allowed_actions.index(params['action'].intern) != nil;
  end 
  
  def index
    @users = User.find(:all, :order => "login")
  end
  
  def new
    @user = User.new
  end
  
  def create
    cpname = params[:user][:content_provider];
    if (!cpname.nil?) then 
      cp = ContentProvider.find_by_name(cpname);
      params[:user][:content_provider] = cp;
      flash[:error] = "Could not find content provider #{cpname}" if cp.nil?
    end
    params[:user][:email] =  params[:user][:email].strip(); 
    @user = User.new(params[:user])
    if @user.save then 
      flash[:notice] = "Account registered!"
      redirect_to :controller => :users, :action => "index"; 
    else
      flash[:error] = "Could not create Account"; 
      render :controller => :users, :action => :new;     
    end 
  end
  
  def edit_user
    if (@current_user.super?) then 
      return User.find(params[:id]);
    else 
      return @current_user
    end
  end
  
  def find 
    redirect_to :action => :index
  end
  
  def show
    @user = edit_user
    respond_to do |format| 
      respond_do(format, @user)
    end 
  end
  
  def edit
    @user = edit_user
  end
  
  def update
    @user = edit_user 
    cp = params[:user].delete(:content_provider)
    if (!cp.nil?) then 
      params[:user][:content_provider] = ContentProvider.find_by_name(cp);
    end
    if @user.update_attributes(params[:user])
      flash[:notice] = "Account updated!"
      redirect_to user_url(@user)
    else
      render :action => :edit, :layout => "login"
    end
  end
  
  def destroy
    @user = User.find(params[:id]);
    @user.destroy; 
    redirect_to :controller => :users, :action => "index"; 
  end
  
  def guess_pwd 
    redirect_to :controller => :user_sessions, :action => :new_guess_pwd; 
  end
end
