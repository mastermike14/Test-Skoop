require 'test_helper'

class User
  def ldap_auth(*args)
    true
  end
end

class WelcomeControllerTest < ActionController::TestCase
  # Replace this with your real tests.

  fixtures :users

  test "should get main pages" do
  	get :help
  	assert_response :success
  	get :about
  	assert_response :success
  	get :contact
  	assert_response :success
  end

  test "can login user already oauth verified" do
    ## POST ApplicationController#login_user
    ## Password not supplied to to ldap_auth override
    post :login_user, :login => {:username => users(:Jacob).uid}
    assert_redirected_to groups_path
  end

  test "can login user needs oauth verified" do
    post :login_user, :login => {:username => users(:Matt).uid}
    assert_redirected_to create_session_path(%q{user})  
  end

  test "should not login" do
    post :login_user, :login => {:username => "nothing"}  
    ## Code needs to be changed if we do not want it to redirect to root path for incorrect login
    assert_redirected_to root_path
  end

end
