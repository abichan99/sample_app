class AccountActivationController < ApplicationController
  def edit
    activation_token = params[:id]
    email = params[:email]
    user = User.find_by(email: email)

    # ユーザーがすでに有効化されているとき
    unless user && !user.activated?
      # バリデーションロジックをばれたくないので、わざとあいまいなエラーメッセージにしている。
      flash[:danger] = 'Invalid activation link'
      redirect_to root_path
      return
    end

    # 有効化トークンが無効なとき
    unless user && user.authenticated?(:activation, activation_token)
      flash[:danger] = 'Invalid activation link'
      redirect_to root_path
      return
    end
    
    # 正規の場合
    user.activate
    log_in user
    flash[:success] = 'Account activated!'
    redirect_to user
  end
end
