require 'test_helper'

class User
  def ldap_exists?(*args)
    true
  end
end

class UserTest < ActiveSupport::TestCase
  # Replace this with your real tests.

  fixtures :users 

  test "blank user is invalid" do
	  newuser = User.new
	  assert !newuser.valid?
  end

  test "create valid user" do
    user = User.new
    assert user.ldap_exists?
    user.uid = "test123"
    user.firstname = "test"
    user.lastname = "test"
    user.email = "test@email.com"
    assert user.valid? 
  end

end
