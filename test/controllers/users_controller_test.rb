require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

  # index

  test "index - redirect when not logged in" do
    get users_path
    assert_redirected_to login_path
  end

  test "show all users when logged in" do
    log_in_as @user
    get users_path
    assert_template "users/index"
  end

  # new

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

  test "disallow admin attribute to be edited via the web" do
    log_in_as @other_user
    assert_not @other_user.admin?
    patch user_path(@other_user), params: { user: {   name:  'michael',
                                      email: 'valid_email@c.c',
                                      password:              'password',
                                      password_confirmation: 'password',
                                      admin: true } }
    assert_not @other_user.reload.admin?                                  
  end

  # destroy

  test "destroy - redirect when not logged in" do
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_response :see_other
    assert_redirected_to login_url
  end

  test "redirect when logged in as a non-admin" do
    log_in_as(@other_user)
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_response :see_other
    assert_redirected_to root_url
  end

  test "associated microposts are deleted when user is deleted" do
    log_in_as @user
    num_microposts = @user.microposts.count
    assert_difference 'Micropost.count', -num_microposts do
      @user.destroy
    end
  end
end
