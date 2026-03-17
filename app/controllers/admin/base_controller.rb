class Admin::BaseController < ApplicationController
  layout "admin"
  before_action :authenticate_user!
  before_action :authorize_admin!

   include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  private

  def authorize_admin!
    redirect_to root_path, alert: "Access denied." unless current_user&.admin?
  end

  def user_not_authorized
    redirect_to admin_root_path, alert: "You are not authorized to perform this action."
  end
end
