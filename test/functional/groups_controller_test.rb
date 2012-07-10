require 'test_helper'

class User
  def create_following(*args)
    true
  end
  def destroy_following(*args)
    true
  end
end

class GroupsControllerTest < ActionController::TestCase

  fixtures :groups
  fixtures :users


  test "should get main pages" do
    session[:user] = users(:Jacob).id
    get :index
    assert_response :success
   end

  test "should logout" do
    session[:user] = users(:Jacob).id
    get :logout
    assert_redirected_to root_path  
  end

  test "should redirect from show" do
    get :show, :id => groups(:Ruby).to_param
    assert_redirected_to root_path
  end

  test "should show group while logged in" do
    session[:user] = users(:Jacob).id
    get :show, :id => groups(:Ruby).to_param
    assert_response :success
  end

  test "user can join group" do
    session[:user] = users(:Jacob).id
    post :add, :group => groups(:Ruby).id
    assert_redirected_to groups_path
  end

  test "user can leave group" do
    session[:user] = users(:Jacob).id
    post :remove, :id => groups(:Ruby).id
    assert_redirected_to groups_path
  end

  ## Admin tests below

  test "admin create group as admin" do
    session[:admin] = admins(:skloop).id
    post :create, :group => { :name => 'new_group_account', :owner => 'skloop', :desc => 'new group', 'twitter_id' => 1 }    
    assert_redirected_to create_session_url(%q{group})
  end

  test "should get admin_index as admin" do
    get :admin_index
    assert_redirected_to login_admin_path
    session[:admin] = admins(:skloop).id
    get :admin_index
    assert_response :success
  end

  test "can destroy group as admin" do
    session[:admin] = admins(:skloop).id
    assert_difference('Group.count', -1) do
      post :destroy, :id => groups(:Ruby).id
    end
    assert_redirected_to admins_path
  end

end
