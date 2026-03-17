# app/policies/admin/dashboard_policy.rb
class Admin::DashboardPolicy < ApplicationPolicy
  def index?
    user.admin?
  end
end
