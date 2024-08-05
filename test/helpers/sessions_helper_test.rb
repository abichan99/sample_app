require "test_helper"

class SessionsHelperTest < ActionView::TestCase

  def setup
    @user = users(:michael)
    remember @user
  end

  test "current_user returns right user when session_token is nil" do
    assert_equal current_user, @user
    assert is_logged_in?
  end
  
  test "current_user returns nil when remember_token is wrong" do
    @user.update_attribute(:remember_digest, User.digest(User.new_token))
    assert_nil current_user
  end  
end