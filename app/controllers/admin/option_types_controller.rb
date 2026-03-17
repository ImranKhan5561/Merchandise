module Admin
  class OptionTypesController < BaseController
    before_action :set_option_type, only: [:edit, :update, :destroy]

    def index
      authorize OptionType
      @option_types = OptionType.includes(:products).all
    end

    def new
      authorize OptionType
      @option_type = OptionType.new
      @option_type.option_values.build # Blank value
    end

    def create
      authorize OptionType
      @option_type = OptionType.new(option_type_params)

      if @option_type.save
        redirect_to admin_option_types_path, notice: "Option Type created successfully."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @option_type
    end

    def update
      authorize @option_type
      if @option_type.update(option_type_params)
        redirect_to admin_option_types_path, notice: "Option Type updated successfully."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @option_type
      @option_type.destroy
      redirect_to admin_option_types_path, notice: "Option Type deleted successfully."
    end

    private

    def set_option_type
      @option_type = OptionType.find(params[:id])
    end

    def option_type_params
      params.require(:option_type).permit(
        :name, :presentation, :category_id,
        option_values_attributes: [:id, :value, :presentation, :_destroy]
      )
    end
  end
end
