class Api::BannersController < Api::ApplicationController
  before_action :authenticate_user!, except: [:index]
  before_action :ensure_admin!, only: [:create, :update, :destroy]
  before_action :set_banner, only: [:update, :destroy]

  def index
    @banners = Banner.active.ordered
    render json: {
      status: { code: 200, message: 'Banners fetched successfully.' },
      data: { banners: @banners }
    }, status: :ok
  end

  def create
    @banner = Banner.new(banner_params)
    if @banner.save
      render json: {
        status: { code: 201, message: 'Banner created successfully.' },
        data: { banner: @banner }
      }, status: :created
    else
      render json: {
        status: { message: @banner.errors.full_messages.to_sentence }
      }, status: :unprocessable_entity
    end
  end

  def update
    if @banner.update(banner_params)
      render json: {
        status: { code: 200, message: 'Banner updated successfully.' },
        data: { banner: @banner }
      }, status: :ok
    else
      render json: {
        status: { message: @banner.errors.full_messages.to_sentence }
      }, status: :unprocessable_entity
    end
  end

  def destroy
    @banner.destroy
    render json: {
      status: { code: 200, message: 'Banner deleted successfully.' }
    }, status: :ok
  end

  private

  def set_banner
    @banner = Banner.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { status: { message: 'Banner not found.' } }, status: :not_found
  end

  def ensure_admin!
    unless current_user.admin?
      render json: { status: { message: 'Unauthorized actions.' } }, status: :unauthorized
    end
  end

  def banner_params
    params.require(:banner).permit(
      :title, :subtitle, :badge_text, :description,
      :button_text, :button_link, :image_url,
      :position, :active, :text_align
    )
  end
end
