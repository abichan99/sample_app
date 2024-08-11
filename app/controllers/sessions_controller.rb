class SessionsController < ApplicationController
  include SessionsHelper
  def new
  end

  def create
    @user = User.find_by(email: params[:session][:email].downcase)

    # パスワードが違うとき
    unless @user && @user.authenticate(params[:session][:password])
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new', status: :unprocessable_entity
      return
    end

    # ユーザーが有効化されていないとき
    unless @user && @user.activated?
      flash[:warning] = "Account is not activated. Check your activation email."
      redirect_to root_path
      return
    end

    # 正常系
    forwarding_url = session[:forwarding_url]
    reset_session
    params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
    log_in @user
    redirect_to forwarding_url || @user
  end

  def destroy
    log_out if logged_in? # 複数のタブでログアウトするときのエラー対策
    redirect_to root_path, status: :see_other
  end
end
