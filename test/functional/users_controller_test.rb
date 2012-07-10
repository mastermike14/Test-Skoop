require 'test_helper'

class User
  def ldap_exists?(*args)
    true
  end
end

class UsersControllerTest < ActionController::TestCase

  fixtures :users

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user and redirect to new oauth session" do
    assert_difference('User.count') do
      post :create, :user => { :firstname => 'test', :lastname => 'test', :email => 'user@test.rb', :uid => 'usertest' }
    end

    assert_redirected_to create_session_path(%q{user})
  end

  test "should go through all steps in wizard and create user" do
    user = User.new
    user.aasm_state
  end

  test "should not get edit" do
    get :edit
    assert_redirected_to root_path
  end

  test "should get edit while logged in" do
    session[:user] = users(:Jacob).id
    get :edit
    assert_response :success
  end

  test "should update user" do
    session[:user] = users(:Jacob).id
    post :edit, :user => { :email => 'newtest@email.com' }
    assert_redirected_to groups_path
  end

end
