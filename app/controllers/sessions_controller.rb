class SessionsController < ApplicationController
  def new
    @user = User.new
  end

  def create
    login = params[:login]&.strip
    user = User.where('lower(email) = ? OR lower(name) = ?', login&.downcase, login&.downcase).first
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_path, notice: "ログインしました"
    else
      flash.now[:alert] = "メールアドレスかパスワードが無効です"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session.delete(:user_id)
    redirect_to root_path, notice: "ログアウトしました"
  end
end