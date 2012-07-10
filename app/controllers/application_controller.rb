class ApplicationController < ActionController::Base
  include Twitter::AuthenticationHelpers

  helper :all 
  protect_from_forgery 
# See ActionController::RequestForgeryProtection for details
  filter_parameter_logging :password, :password_confirmation
  before_filter :get_active_page

  layout 'skloop'

  rescue_from Twitter::Unavailable, :with => :twitter_unavailable
  rescue_from Errno::ECONNRESET, :with => :connection_reset

  def get_active_page
	## This method gets the active page so that it can use it in the navigation for active links
	  @active = request.parameters[:action]
  end

  def login_required
    unless defined? RAILS_BETA
  	  if session[:user]
  		  true
  	  else
  		  flash[:notice] = "Please login to continue"
  		  redirect_to root_path
  	  end
    else
      flash[:notice] = "Skloop is currently in beta. Thank you for registering, we will be launching our system for student use on March 2nd. Check back soon!"
      redirect_to root_path
    end
  end

  def no_login_required
    begin
    if session[:user]
      unless defined? RAILS_BETA
        redirect_to groups_path
      else
        session[:user] = nil
      end
    elsif session[:admin]
      redirect_to admins_path
    end
    rescue ActionController::SessionRestoreError
      session[:user] = nil
      session[:admin] = nil
      redirect_to root_path
    end
  end

  def admin_required
    if session[:admin]
      session[:user] = nil unless session[:user].nil?
      true
    else
      flash[:notice] = "Please login to continue"
      redirect_to login_admin_path
    end
  end

 def login_user
	  if @user = User.find_by_uid(params[:login][:username])
        login = params[:login]
        if @user.ldap_auth(login[:username], login[:password])
          unless @user.atoken.present? and @user.asecret.present?
            session[:uid] = @user.uid
            @user.aasm_state = "info"
            flash[:notice] = "Welcome back to Skloop. It appears you have not connected your Twitter account yet. Follow the rest of the wizard to finish this process so that you can join your groups."
            render :action => 'new'
          else
            session[:user] = @user.id
            session[:fullname] = @user.full_name
			      redirect_to groups_path
            flash[:notice]="Successfully logged in"
          end
        else
          flash[:error]= "Your password is incorrect"
          redirect_to root_url
        end
    else
      flash[:error] = "That username doesn't exist"
      redirect_to root_url
    end
  end

  def twitter_unavailable
    render :page => 'welcome/unavailable'
  end
  
  def connection_reset
    flash[:notice] = "There was an error processing your request. Please try again"
    url = case request.parameters[:controller]
      when 'admins'
        admins_url
      when 'groups'
        groups_url
      when 'users'
        users_url
    end
    redirect_to url
  end

  def hide
    render :update do |page|
      page.visual_effect(:DropOut, :notice)
    end
  end
 
  private
    def force_sign_in(exception)
      reset_session
      flash[:error] = 'Seems your credentials are not good anymore. Please sign in again.'
      redirect_to root_url
    end
end
