class ApplicationController < ActionController::Base
  include SessionsHelper

  # ログイン済みユーザーかどうか確認
  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = 'Please log in'
    redirect_to login_path, status: :see_other
  end
  
  def correct_user
    return if current_user?(User.find(params[:id]))

    flash[:danger] = 'You have no permission'
    redirect_to(root_url, status: :see_other)
  end

  def admin_user
    return if current_user.admin?

    flash[:danger] = 'You have no permission'
    redirect_to(root_url, status: :see_other)
  end
end
