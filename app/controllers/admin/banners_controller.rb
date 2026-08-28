class Admin::BannersController < Admin::BaseController
  before_action :set_banner, only: [:edit, :update, :destroy]

  def index
    @banners = Banner.ordered
  end

  def new
    @banner = Banner.new(position: (Banner.maximum(:position) || 0) + 1, active: true, text_align: 'left', button_text: 'Discover Collection', button_link: '/browse')
  end

  def create
    @banner = Banner.new(banner_params)
    if @banner.save
      redirect_to admin_banners_path, notice: 'Banner created successfully.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @banner.update(banner_params)
      redirect_to admin_banners_path, notice: 'Banner updated successfully.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @banner.destroy
    redirect_to admin_banners_path, notice: 'Banner deleted successfully.'
  end

  private

  def set_banner
    @banner = Banner.find(params[:id])
  end

  def banner_params
    params.require(:banner).permit(
      :title, :subtitle, :badge_text, :description,
      :button_text, :button_link, :image_url, :image,
      :position, :active, :text_align
    )
  end
end
