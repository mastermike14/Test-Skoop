class WelcomeController < ApplicationController

  layout 'skloop'

  before_filter :no_login_required, :only => 'index'

  def index
   @title = "Welcome"
   @user = User.new
    respond_to do |format|
      format.html
      format.xml  { render :xml => @user }
    end
  end

  def about
	  @title = "About Skloop"
  end

  def help
	  @title = "Help"
  end

  def contact
  @title= "Contact Us"
  if request.post?
   @message= Message.new(params[:contact])
    if @message.valid?
       UserMailer.deliver_message(
        :message => @message
        )
        #UserMailer.deliver_user_message(
        #:message => @message
        #)
      flash[:notice] = "Thank you for contacting us"
      redirect_to contact_url
     end
    end
  end

end
