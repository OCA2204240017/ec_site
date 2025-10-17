module Admin
  class SessionsController < ApplicationController
    layout 'admin'

    def new; end

    def create
      admin = Admin.find_by(email: params[:email]&.downcase)
      if admin&.authenticate(params[:password])
        session[:admin_id] = admin.id
        redirect_to admin_books_path, notice: '管理者でログインしました'
      else
        flash.now[:alert] = 'メールアドレスかパスワードが無効です'
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      session.delete(:admin_id)
      redirect_to new_admin_session_path, notice: 'ログアウトしました'
    end
  end
end
