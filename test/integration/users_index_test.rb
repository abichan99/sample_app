require "test_helper"

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test "paginated when there are many users" do
    log_in_as @user
    get users_path
    assert_template "users/index"
    assert_select "a[href=?]", users_path(page: 1), count: 2
  end
end
