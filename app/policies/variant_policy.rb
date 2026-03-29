class VariantPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def create?
    user.admin?
  end

  def update?
    user.admin?
  end

  def destroy?
    user.admin?
  end

  def update_visual_settings?
    user.admin?
  end

  def bulk_update_images?
    user.admin?
  end
end
