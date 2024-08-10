require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

  test "should get new" do
    get signup_url
    assert_response :success
  end

  # edit

  test "redirect when attempt to edit other user" do
    log_in_as @user
    get edit_user_path @other_user
    assert_not flash.empty?
    assert_redirected_to root_path
  end
  
  # update

  test "redirect when attempt to update other user" do
    log_in_as @user
    patch user_path(@other_user)
    assert_not flash.empty?
    assert_redirected_to root_path
  end

  # index

  test "redirect when not logged in" do
    get users_path
    assert_redirected_to login_path
  end

  test "show all users when logged in" do
    log_in_as @user
    get users_path
    assert_template "users/index"
  end
end
