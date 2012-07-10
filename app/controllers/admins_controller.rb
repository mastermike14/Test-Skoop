class AdminsController < ApplicationController

  before_filter :admin_required, :except => "login"

  layout 'skloop'

  def index
    @admin = Group.new
    @title = "Your Groups"
    @user = Admin.find(session[:admin])
    respond_to do |format|
      format.html
      format.xml  { render :xml => @admins }
    end
  end

  def login
    @title = "Login to Continue"
    if request.post?
      info = params[:login]
      a = Admin.authenticate(info[:username], info[:password])
      unless a.nil?
        session[:admin] = a.id
        session[:fullname] = a.full_name
        flash[:notice] = "You have successfully logged in"
        redirect_to admin_index_path
      else
        flash.now[:error] = "Incorrect username/password"
      end
    end
  end

 def users
   @admin = Admin.find(session[:admin])
   name = params[:name]
   @group = Group.find_by_name(name)
   @users = @group.users.paginate :page => params[:page], :per_page => 20
   @title = "#{@group.name} 's Members"
 end

 def direct_msg
  @admin = Admin.find(session[:admin])
  name = params[:name]
  @group = Group.find_by_name(name)
  @users= @group.users(@group)
  if request.post?
   message= params[:direct_msg]

  @user = User.find(message[:id])
   @text= message[:body]
    if @text.blank?
      flash.now[:error]="Message can not be blank!"
    else
     @group.client.direct_message_create(@user.username, @text)
    end
   end
    rescue ActiveRecord::RecordNotFound
     flash.now[:error]="You must specify a student to send a message to"
  end 

  def message
    @title = "Send a Message"
    @user = Admin.find(session[:admin])
    @group = [Group.find(params[:id])] if params[:id]
    if request.post?
      info = params[:message]
      group= Group.find(info[:id])
      text= info[:body]
      id = info[:id]
      if text.blank?
        flash.now[:error]= "Message can not be blank!"
      else
       if id.blank? or id.nil?

         flash.now[:error]= "You must specify a group"
        else
         if @user.owner?(info[:id])
          group.client.update(text)
          flash.now[:notice]= "Status update successfully sent!"
           else 
          redirect_to admins_url
          flash[:notice]= "You do not have permission to access that page"
         end
        end
       end
      end
       rescue ActiveRecord::RecordNotFound
        flash.now[:error]= "You must specify a group"

     end

  def logout
    session[:admin] = nil
    redirect_to root_path
  end

  def profile
      name = params[:name]
      @group= Group.find_by_name(name)
      @title= "#{@group.name}'s Group Page"
      @status = @group.client.user_timeline(:count => 5)
    rescue NoMethodError
      redirect_to groups_path
      flash[:notice]="That group does not exist. Please check your spelling and try again"
  end

  def edit
    @title = "Edit a Group"
    @admin = Group.find_by_name(params[:name])
    @admins = Admin.find(session[:admin])
    unless @admins.owner?(@admin)
     flash[:notice]="You must be the teacher of that group in order to edit  it"
     redirect_to admins_url
    end 
  end

  def update
    @admin = Group.find_by_name(params[:name])
    respond_to do |format|
      if @admin.update_attributes(params[:group])
        flash[:notice] = 'Group was successfully updated.'
        format.html { redirect_to admins_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @admin.errors, :status => :unprocessable_entity }
      end
    end
  end

  def reset_group
    @group = Group.find(params[:id])
    @group.reset
    flash[:notice] = "Group has been reset"
    redirect_to admin_profile_path(@group.name)
  end

  def remove_user
    @user = User.find(params[:id])
    @group = Group.find(params[:group])
    @admin = Admin.find(session[:admin])
    if @user.assigned_to?(@group) and @admin.owner?(@group.id)
      @user.destroy_following(@group)
      flash[:notice] = "Successfully removed user"
    end
    respond_to do |format|
      format.html { render :action => admins_path }
      format.js { render :update do |page|
        page.remove dom_id(@group)
      end }
    end
  end

end
