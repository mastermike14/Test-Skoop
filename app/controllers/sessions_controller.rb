class SessionsController < ApplicationController  
  def new
  end
  
  def create
    oauth.set_callback_url(finalize_session_url(params[:id]))
    session['rtoken']  = oauth.request_token.token
    session['rsecret'] = oauth.request_token.secret
    redirect_to oauth.request_token.authorize_url
  end
  
  def destroy
    reset_session
    redirect_to root_url
    session[:user] = nil
    flash[:notice]="You have been successfully logged out"
  end
  
  def finalize  
	  oauth.authorize_from_request(session['rtoken'], session['rsecret'], params[:oauth_verifier])

        session['rtoken']  = nil
        session['rsecret'] = nil

        profile = Twitter::Base.new(oauth).verify_credentials
        case params[:id].downcase
          when 'user'
            if profile.screen_name.nil? or (profile.screen_name.downcase != session[:username].downcase)
              flash[:notice] = "You need to log out of twitter to continue. After you logout you may login and try again."
              redirect_to root_url
            else
              user = User.find_by_uid(session[:uid])
              session[:uid] = nil 
              user.update_attributes({ 
                :username => profile.screen_name.downcase, 
                :atoken => oauth.access_token.token, 
                :asecret => oauth.access_token.secret 
               })
              session[:user] = user.id
              session[:fullname] = user.full_name
    	        unless user.client.friendship_exists?(user.username, 'skloop')
             	  user.create_following(Group.find_by_name('skloop'))
  	          end
  	          flash[:notice]="Welcome to Skloop! Your account has been linked to twitter and you are now ready to follow groups. Dont forget to setup twitter on your mobile device"
              redirect_to groups_path
            end
          when 'group'
            group = session[:group]
            group.atoken = oauth.access_token.token
            group.asecret = oauth.access_token.secret
            if group.name.downcase == profile.screen_name.downcase
              group.save
	            flash[:notice] = "Your group has been created! To delete your group click destroy, but remember this is permanent!"
            else
              flash[:error] = "The group name and the twitter account name do not match. Check the spelling of the name and make sure you are logged into twitter with the correct account. You may need to <a href=\"http://www.twitter.com/logout\" target=\"_blank\">logout</a> of twitter"
            end
            redirect_to admin_index_path
          when 'parent'
            if profile.screen_name.nil?
              flash[:notice] = "You need to logout of twitter"
              redirect_to parents_path
            end
            parent = session[:parent]
            parent.atoken = oauth.access_token.token
            parent.asecret = oauth.access_token.secret
            if parent.name.downcase == profile.screen_name.downcase
              parent.save
              flash[:notice] = "Your parent has been added! They will recieve all the announcements that you do"
            else
              flash[:error] = "The group name and the twitter account name do not match. Check the spelling of the name and make sure you are logged into twitter with the correct account. You may need to <a href=\"http://www.twitter.com/logout\" target=\"_blank\">logout</a> of twitter"
            end
            redirect_to parents_path
        end

 	        rescue ActionController::InvalidAuthenticityToken
            redirect_to root_url
          rescue Twitter::General
            redirect_to groups_url
	end

private
    def oauth
      @oauth ||= Twitter::OAuth.new(ConsumerConfig['token'], ConsumerConfig['secret'], :sign_in => true)
    end

end
