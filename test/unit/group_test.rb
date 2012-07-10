require 'test_helper'

class GroupTest < ActiveSupport::TestCase

  fixtures :groups

  test "blank user is invalid" do
    group = Group.new
    assert !group.valid?
  end

  test "group should be valid" do
    group = Group.new
    group.name = "test"
    group.owner = "me"
    group.twitter_id = 1
    group.desc = "unit test"
    assert group.valid?
    group = groups(:Ruby)
    assert group.valid?
  end

end
