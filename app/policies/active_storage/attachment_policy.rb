class ActiveStorage::AttachmentPolicy < ApplicationPolicy
  def destroy?
    user.admin?
  end
end
