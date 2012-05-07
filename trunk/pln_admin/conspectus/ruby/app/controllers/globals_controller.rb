class GlobalsController < ApplicationController
  before_filter  :require_by_all; # calls before_all
  
   def before_all
    @page = params[:page] || 1
     @allowed_actions = []; 
     if (super_user?) then 
        @allowed_actions = [:index, :find, :edit,  :update] 
     end 
     #params[:allowed_actions] = @allowed_actions;
    return @allowed_actions.index(params['action'].intern) != nil;
  end 
  
  def index
    @globals = Global.find(:all, :order => :name)
  end
  
  def find
    redirect_to :action => :index  
  end
  
  def edit
    @global = Global.find(params[:id])
  end
  
  def update
    @global = Global.find(params[:id])
    if @global.update_attributes(params[:global])
      flash[:notice] = "Global setting updated!"
      redirect_to globals_url
    else
      render :action => :edit, :layout => "login"
    end
  end

end
