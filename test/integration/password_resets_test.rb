require "test_helper"
class PasswordResets < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
  end
end

class ForgotPasswordFormTest < PasswordResets
  test 'password reset path' do
    get new_password_reset_path
    assert_template 'password_resets/new'
    assert_select 'input[name=?]', 'password_reset[email]'
  end

  test 'reset path with invalid email' do
    post password_resets_path, params: { password_reset: { email: '' } }
    assert_response :unprocessable_entity
    assert_not flash.empty?
    assert_template 'password_resets/new'
  end
end

class PasswordResetForm < PasswordResets
  def setup
    super
    @user = users(:michael)
    post password_resets_path,
         params: { password_reset: { email: @user.email } }
    @reset_user = assigns(:user)
  end
end

class PasswordResetFormTest < PasswordResetForm
  test 'reset with valid email' do
    assert_not_equal @reset_user.reset_digest, @user.reset_digest
    assert_equal ActionMailer::Base.deliveries.size, 1
    assert_not flash.empty?
    assert_redirected_to root_path
  end

  test 'reset with wrong email' do
    get edit_password_reset_path(@reset_user.reset_token,
                                  email: '')
    assert_redirected_to root_path
  end
  
  test 'reset with inactive user' do
    @reset_user.update_attribute(:activated, false)
    get edit_password_reset_path(@reset_user.reset_token,
                                  email: @reset_user.email)
    assert_redirected_to root_path
  end
  
  test 'reset with right email and token' do
    get edit_password_reset_path(@reset_user.reset_token,
                                  email: @reset_user.email)
    assert_select 'input[name=email][type=hidden][value=?]', @reset_user.email
  end
end

class UpdatePasswordTest < PasswordResetForm
  test 'reset with empty password' do
    patch password_reset_path(@reset_user.reset_token,
                                params: { email: @reset_user.email,
                                          user: { password:              '',
                                                  password_confirmation: '' } })
    assert_select 'div#error_explanation'
  end

  test 'reset with invalid password' do
    patch password_reset_path(@reset_user.reset_token,
                                params: { email: @reset_user.email,
                                          user: { password:              'foo',
                                                  password_confirmation: 'bar' } })
    assert_select 'div#error_explanation'
  end
  
  test 'update with valid password and confirmation' do
    patch password_reset_path(@reset_user.reset_token,
                                params: { email: @reset_user.email,
                                          user: { password:              'foo1234',
                                                  password_confirmation: 'foo1234' } })
    assert_not flash.empty?
    assert_redirected_to @user
    assert is_logged_in?
    assert_not_equal @user.password_digest, @user.reload.password_digest
  end
end

class ExpiredToken < PasswordResetForm
  def setup
    super
    # トークンを手動で失効させる
    @reset_user.update_attribute(:reset_sent_at, 3.hours.ago)
    # ユーザーのパスワードの更新を試みる
    patch password_reset_path(@reset_user.reset_token),
          params: { email: @reset_user.email,
                    user: { password:              "foobar",
                            password_confirmation: "foobar" } }
  end
end

class ExpiredTokenTest < ExpiredToken

  test "should redirect to the password-reset page" do
    assert_redirected_to new_password_reset_url
  end

  test "should include the word 'expired' on the password-reset page" do
    follow_redirect!
    assert_match /expired/i, response.body
  end
end