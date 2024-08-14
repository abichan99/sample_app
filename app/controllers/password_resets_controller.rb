class PasswordResetsController < ApplicationController
  before_action :get_user,   only: [:edit, :update]
  before_action :validate_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]

  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    unless @user
      flash.now[:danger] = 'Email address not found'
      render 'new', status: :unprocessable_entity
      return
    end

    @user.create_reset_digest
    @user.send_password_reset_email
    flash[:info] = 'Email sent with password reset instructions'
    redirect_to root_path
  end

  def edit
  end

  def update
    # パスワードフィールドが空の時
    if params[:user][:password].empty?
      @user.errors.add(:password, :blank)
      render 'edit', status: :unprocessable_entity
      return
    end

    if @user.update(user_params)
      @user.forget
      reset_session
      log_in @user
      @user.update_attribute(:reset_digest, nil)
      flash[:info] = 'Password has been successfully updated'
      redirect_to @user
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def get_user
    @user = User.find_by(email: params[:email])
  end

  def validate_user
    reset_token = params[:id]

    # ユーザーが有効化されていないとき
    unless @user && @user.activated?
      flash[:danger] = 'User is not activated. Check your activation email.'
      redirect_to root_path
      return
    end

    # リセットトークンが無効なとき
    unless @user && @user.authenticated?(:reset, reset_token)
      flash[:danger] = 'Invalid activation link'
      redirect_to root_path
    end
  end

  def check_expiration
    if @user.password_reset_expired?
      flash[:danger] = 'Password reset has expired.'
      redirect_to new_password_reset_path
    end
  end
end
