class Api::PincodesController < Api::ApplicationController
  def check
    if params[:code].blank?
      return render json: { available: false, message: 'Pincode is missing' }, status: :bad_request
    end

    pincode = ServiceablePincode.active.find_by(code: params[:code].to_s.strip)

    if pincode
      render json: { available: true, message: 'Delivery is available for this pincode.' }
    else
      render json: { available: false, message: 'Sorry, we do not deliver to this pincode yet.' }
    end
  end
end
