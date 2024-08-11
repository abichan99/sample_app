class AccountActivationController < ApplicationController
  def edit
    activation_token = params[:id]
    email = params[:email]
    user = User.find_by(email: email)
    
    if user && !user.activated? && user.authenticated?(:activation, activation_token)
      user.activate
      log_in user
      flash[:success] = 'Account activated!'
      redirect_to user
    else
      flash[:danger] = 'Invalid activation link'
      redirect_to root_path
    end
  end
end
