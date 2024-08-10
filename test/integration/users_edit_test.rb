require "test_helper"

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end
  
  test "unsuccessful test" do
    log_in_as @user
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), params: { user: {   name:  'michael',
                                                email: 'invalid email',
                                                password:              'foo',
                                                password_confirmation: 'bar' } }
    assert_template 'users/edit'
    assert_select "#error_explanation div", "The form contains 3 errors."
  end
  
  test "successful test with friendly forwarding" do
    get edit_user_path(@user)
    log_in_as @user
    assert_redirected_to edit_user_path(@user)
    assert_nil session[:forwarding_url]
    patch user_path(@user), params: { user: {   name:  'michael',
                                                email: 'valid_email@c.c',
                                                password:              'password',
                                                password_confirmation: 'password' } }
    assert_redirected_to @user
    assert_not flash.empty?
    @user.reload
    assert_equal @user.email, 'valid_email@c.c'
  end
end
