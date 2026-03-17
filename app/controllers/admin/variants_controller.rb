module Admin
  class VariantsController < BaseController
    before_action :set_product
    before_action :set_variant, only: [:edit, :update, :destroy]

    def index
      authorize Variant
      @variants = @product.variants.includes(:option_values)
    end

    def update_visual_settings
      authorize Variant
      visual_ids = params[:visual_option_type_ids]&.reject(&:blank?)&.map(&:to_i) || []
      
      @product.product_option_types.each do |pot|
        pot.update!(is_visual: visual_ids.include?(pot.option_type_id))
      end
      
      redirect_to admin_product_variants_path(@product), notice: "Visual settings saved."
    end

    def new
      authorize Variant
      @variant = @product.variants.build
    end

    def create
      authorize Variant
      @variant = @product.variants.build(variant_params)

      if @variant.save
        redirect_to admin_product_variants_path(@product), notice: "Variant created successfully."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @variant
    end

    def update
      authorize @variant
      if @variant.update(variant_params)
        redirect_to admin_product_variants_path(@product), notice: "Variant updated successfully."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @variant
      @variant.destroy
      redirect_to admin_product_variants_path(@product), notice: "Variant deleted successfully."
    end

    private

    def set_product
      @product = Product.find(params[:product_id])
    end

    def set_variant
      @variant = @product.variants.find(params[:id])
    end

    def variant_params
      params.require(:variant).permit(
        :sku, :price, :stock_quantity, :weight, :is_master,
        { images: [] },
        option_value_ids: []
      )
    end
  end
end
