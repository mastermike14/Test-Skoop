class GroupsController < ApplicationController

  before_filter :login_required, :except => ["create", "edit", "destroy", "admin_index", "update", "hide"]
  before_filter :admin_required, :only => ["create", "edit", "destroy", "admin_index", "update"]

  layout 'skloop'

  # GET /groups
  # GET /groups.xml
  def index
    @user = User.find(session[:user])
    @title = "All Groups"
    if params[:search]
     @groups = Group.search(params[:search], params[:page])
   else
    @groups = Group.paginate :page => params[:page], :per_page => 8
    respond_to do |format|
	    #flash[:notice]= "You are already in every group" unless @user.groups.count < Group.count
      format.html # index.html.erb
      format.xml  { render :xml => @groups }   
    end
   end
 end


 def direct_message
  @title = "Direct Message"
  name   = params[:name]
  @user = User.find(session[:user])
  @user = User.find(@user)
  @group = Group.find_by_name(name)
     if request.post?
    message = params[:direct_message]
    @text   = message[:text]
	if @text.empty? 
	  flash.now[:error]= "Message can not be blank!"
	   else
    @user.client.direct_message_create(@group.name, @text)
    flash.now[:notice] = "Your message has successfully been sent!"
   end
  end
 end

  def show
    @title = "View a Group"
    @group = Group.find(params[:id])
    @title = @group.name
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @group }
    end
    rescue ActiveRecord::RecordNotFound
     flash[:notice]="That group does not exist"
     redirect_to groups_path
  end
  
  def profile
      name = params[:name]
      @group= Group.find_by_name(name)
      @user = User.find(session[:user])
      @title= "#{@group.name}'s Group Page"
    rescue NoMethodError
      redirect_to groups_path
      flash[:notice]="That group does not exist. Please check your spelling and try again"
  end
  
  def teacher
    begin
      owner = params[:owner]
      @group= Group.find_by_owner(owner)
      @title="#{@group.owner}'s Page"
    rescue NoMethodError
      redirect_to root_url
      flash[:notice]= "That teacher does not exist"
    end
  end

  def add
    begin
      @user = User.find(session[:user])
      @group = Group.find(params[:id])
      @groups = Group.paginate :page => params[:page], :per_page => 8
      unless @user.assigned_to?(@group)
        @user.create_following(@group)
        @user.parents.each do |parent|
          parent.create_following(@group)    
        end
        flash.now[:notice]= "You have successfully joined this group and you are now following this group on twitter. You will receive future notifications on your mobile device if you have enabled your device on twitter."
      end
      respond_to do |format|
        format.html { render :action => 'index' }
        format.js 
      end
	rescue Twitter::General
      flash.now[:notice] = "It appears you are already following that account..."
      respond_to do |format|
        format.html { redirect_to groups_path }
        format.js     
      end
    rescue ActiveRecord::RecordNotFound
       redirect_to groups_path
       flash[:notice]= "That is not a valid group"
    rescue Twitter::Unauthorized
        session[:uid] = @user.uid
        redirect_to new_session_path
	  end
       rescue ActiveRecord::StatementInvalid
         redirect_to groups_url
       
  end

  def new
    @title = "Fix your Errors to Continue"
    @admin = Group.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @admin }
    end
  end

  def create
    @title = "Fix your errors to continue"
    @user = Admin.find(session[:admin])
    @admin = Group.new(params[:group])
    respond_to do |format|
      @admin.owner = @user.uid
      if @admin.valid?
        session[:group] = @admin
        format.html { redirect_to create_session_url(%q{group}) }
        format.xml { render :xml => @admin, :status => :created, :location => @admin }
      else
        @admin.save
        format.html { render :action => 'admin_index' }
        format.xml  { render :xml => @admin.errors, :status => :unprocessable_entity }
     end
    end
	rescue ActiveRecord::StatementInvalid
	flash[:error]= "The group name and the twitter account name do not match. Check the spelling of the name and make sure you are logged into twitter with the correct account."
			redirect_to admins_url
  end

  def remove 
    begin
    @user = User.find(session[:user])
    @group = Group.find(params[:id])
    @groups = Group.paginate :page => params[:page], :per_page => 8
    if @user.assigned_to?(@group)
      @user.destroy_following(@group)
      @user.parents.each do |parent|
        parent.destroy_following(@group)
      end
      flash.now[:notice] = "You have successfully left this group. You have stopped following this group on twitter and will no longer receive notifications from this group"
    end
    respond_to do |format|
      format.html { redirect_to groups_path }
      format.js
    end
    rescue Twitter::Unauthorized
    flash[:notice] = "There was an error processing your request. Please try again"
    redirect_to users_path
      session[:uid] = @user.uid
      redirect_to new_session_path
    end
     rescue Twitter::General
      @user.groups.delete(@group.name)
  end

  # DELETE /admins/1
  # DELETE /admins/1.xml
  def destroy
    @user = Admin.find(session[:admin])
    if @user.owner?(params[:id])
      @admin = Group.find(params[:id])
      @admin.destroy
      respond_to do |format|
        format.html { redirect_to(admins_path) }
        format.xml  { head :ok }
      end
    else
      redirect_to admins_path
    end
  end

  def logout
    session[:user] = nil
    redirect_to root_path
  end

  def admin_index
    @admin = Group.new
    @title = "Your Groups"
    @user = Admin.find(session[:admin])
    respond_to do |format|
      format.html
      format.xml  { render :xml => @admins }
    end
  end

  def edit
    @admin = Group.find(params[:admin])
  end

end
