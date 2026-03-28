class Api::AddressesController < Api::ApplicationController
  before_action :authenticate_user!
  before_action :set_address, only: [:update, :destroy]

  def index
    @addresses = current_user.user_addresses.order(is_default: :desc, created_at: :desc)
    render json: {
      status: { code: 200, message: 'Addresses fetched successfully.' },
      data: { addresses: @addresses }
    }, status: :ok
  end

  def create
    @address = current_user.user_addresses.build(address_params)

    if @address.save
      render json: {
        status: { code: 201, message: 'Address created successfully.' },
        data: { address: @address }
      }, status: :created
    else
      render json: {
        status: { message: @address.errors.full_messages.to_sentence }
      }, status: :unprocessable_entity
    end
  end

  def update
    if @address.update(address_params)
      render json: {
        status: { code: 200, message: 'Address updated successfully.' },
        data: { address: @address }
      }, status: :ok
    else
      render json: {
        status: { message: @address.errors.full_messages.to_sentence }
      }, status: :unprocessable_entity
    end
  end

  def destroy
    @address.destroy
    render json: {
      status: { code: 200, message: 'Address deleted successfully.' }
    }, status: :ok
  end

  private

  def set_address
    @address = current_user.user_addresses.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { status: { message: 'Address not found.' } }, status: :not_found
  end

  def address_params
    params.require(:address).permit(:address_type, :address_line_1, :address_line_2, :city, :state, :postal_code, :country, :is_default)
  end
end
