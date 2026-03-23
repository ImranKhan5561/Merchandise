class OrderPolicy < ApplicationPolicy
  def index?
    user.admin? || user.super_admin? rescue true # Fallback context
  end

  def show?
    index?
  end

  def update?
    index?
  end
end
