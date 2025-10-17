module Admin
  class UsersController < ApplicationController
    layout 'admin'
    before_action :require_admin

    def index
      @users = User.all
    end

    private

    def require_admin
      redirect_to new_admin_session_path, alert: '管理者でログインしてください' unless session[:admin_id] && Admin.find_by(id: session[:admin_id])
    end
  end
end
