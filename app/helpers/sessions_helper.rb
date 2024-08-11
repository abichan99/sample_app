module SessionsHelper
  def remember(user)
    user.remember
    cookies.permanent.encrypted[:user_id] = user.id # 生の user.id だとクッキー値が改変されてほかのユーザーに成りすまされる危険がある。
    cookies.permanent[:remember_token] = user.remember_token
  end

  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  def log_in(user)
    session[:user_id] = user.id
    # セッションリプレイ攻撃から保護する
    # 詳しくは https://techracho.bpsinc.jp/hachi8833/2023_06_02/130443 を参照
    session[:session_token] = user.session_token
  end

  def log_out
    forget(current_user)
    reset_session
    @current_user = nil # 安全のため
  end

  def current_user
    if (user_id = session[:user_id])
      user = User.find(user_id)
      if session[:session_token] == user.session_token
        @current_user = user
      end
    elsif (user_id = cookies.encrypted[:user_id])
      user = User.find(user_id)
      if user && user.authenticated?(:remember, cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  def current_user?(user)
    user && user == current_user
  end

  def logged_in?
    !current_user.nil?
  end

  # アクセスしようとする url を保存する
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
end
