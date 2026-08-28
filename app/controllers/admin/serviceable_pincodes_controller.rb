class Admin::ServiceablePincodesController < Admin::BaseController
  before_action :set_pincode, only: [:edit, :update, :destroy]

  def index
    @pincodes = ServiceablePincode.order(created_at: :desc)
    
    if params[:query].present?
      @pincodes = @pincodes.where("code ILIKE ?", "%#{params[:query]}%")
    end
  end

  def new
    @pincode = ServiceablePincode.new(active: true)
  end

  def create
    @pincode = ServiceablePincode.new(pincode_params)
    if @pincode.save
      redirect_to admin_serviceable_pincodes_path, notice: 'Pincode was added successfully.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @pincode.update(pincode_params)
      redirect_to admin_serviceable_pincodes_path, notice: 'Pincode updated successfully.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @pincode.destroy
    redirect_to admin_serviceable_pincodes_path, notice: 'Pincode deleted successfully.'
  end

  private

  def set_pincode
    @pincode = ServiceablePincode.find(params[:id])
  end

  def pincode_params
    params.require(:serviceable_pincode).permit(:code, :active)
  end
end
