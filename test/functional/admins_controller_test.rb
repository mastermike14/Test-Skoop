require 'test_helper'

class AdminsControllerTest < ActionController::TestCase

  fixtures :admins, :groups

  test "should show admin profile when logged in" do
    session[:admin] = admins(:skloop).id
    get :profile, :name => groups(:Ruby).name
    assert_response :success
  end

  test "should redirect when not logged in" do
    get :profile, :name => groups(:Ruby).to_param
    assert_redirected_to login_admins_path
  end

  test "should show message page" do
    session[:admin] = admins(:skloop).id
    get :message
    assert_response :success
  end

  test "should not show message page" do
    get :message
    assert_redirected_to login_admins_path 
  end

end
