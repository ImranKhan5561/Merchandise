class Admin::DashboardController < Admin::BaseController
  def index
     authorize [:admin, :dashboard], :index?
  end
end
