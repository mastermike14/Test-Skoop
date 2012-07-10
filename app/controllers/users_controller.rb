class UsersController < ApplicationController

  before_filter :no_login_required, :only => ['new', 'create', 'login', 'login_user']

  layout 'skloop'

  def index
    redirect_to root_url
  end

  def info
    @title= "Basic Info"
    @user= session[:user]
  end

  def edit
   @title = "Edit Your Information"
   @user = User.find(session[:user])
    if request.post?
      attribute= params[:attribute]
     if @user.update_attributes(params[:user])
      flash[:notice] = "Email updated."
      redirect_to groups_path
     end
   end
  end
  # GET /users/new
  # GET /users/new.xml
  def new
    @title = "Create an account"
    @user = User.new
    session[:create_user] = @user
    @user.aasm_state
    case params[:direction]
      when 'next'
        @user.aasm_direction('next')
    end
    respond_to do |format|
      format.html 
      format.xml  { render :xml => @user }
    end
  end

  def create
    if session[:create_user]
      @title = "Create an account"
      @user = session[:create_user]
      @user.attributes = params[:user]
      case params[:direction]
        when 'previous'
          @user.aasm_direction('previous')
      end
      respond_to do |format|
        if @user.valid?
          @user.save
          session[:uid] = @user.uid
          UserMailer.deliver_post_registration(@user)
          @user.aasm_direction('next')
        end
        format.html { render :action => 'new' } 
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }   
      end
    else
      render new_user_path
    end
  end

  def update
    if session[:create_user]
      @user = session[:create_user]
      if params[:user]
        @user = session[:create_user]
        @user.attributes= params[:user]
        case params[:direction]
          when 'next'
            @user.aasm_direction('next') if @user.valid?
          when 'previous'
            @user.aasm_direction('previous')
          when 'register'
            session[:create_user] = nil
            session[:username] = @user.username
        end
        respond_to do |format|
          session[:create_user] = @user
          format.html { @user.username.nil? ? (render :action => 'new') : (redirect_to create_session_url(%q{user})) }
        end
      else
        case params[:direction]
          when 'next'
            if params[:agree] == "yes"
              @user.aasm_direction('next')
            else
              flash.now[:error] = "You must agree to the terms to continue"
            end
          when 'previous'
              @user.aasm_direction('previous')
        end
        respond_to do |format|
          session[:create_user] = @user
          format.html { render :action => 'new' }        
        end
      end
    end
  end

end
