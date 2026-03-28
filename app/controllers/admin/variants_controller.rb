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

    def bulk_update_images
      authorize Variant
      option_value_ids = params[:option_value_ids_key].to_s.split('-').map(&:to_i)
      images = params[:images]
      
      if images.present? && option_value_ids.any?
        variants = @product.variants.includes(:option_values).select do |v|
          (option_value_ids - v.option_value_ids).empty?
        end
        
        variants.each { |v| v.images.attach(images) }
        notice = "Successfully attached #{images.count} image(s) to #{variants.count} variant(s)."
      else
        notice = "No images provided."
      end
      
      redirect_to admin_product_variants_path(@product), notice: notice
    end

    def new
      authorize Variant
      @variant = @product.variants.build
    end

    def create
      authorize Variant
      @variant = @product.variants.build(variant_params.except(:images))
      images = params[:variant][:images]
      option_value_ids = extract_option_value_ids

      if @variant.save
        @variant.option_values = OptionValue.where(id: option_value_ids) if option_value_ids.any?
        @variant.images.attach(images) if images.present?
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
      images = params[:variant][:images]
      option_value_ids = extract_option_value_ids

      if @variant.update(variant_params.except(:images))
        @variant.option_values = OptionValue.where(id: option_value_ids) if option_value_ids.any?
        @variant.images.attach(images) if images.present?
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

    # The form sends option_value_ids keyed by option_type_id:
    # variant[option_value_ids][42] = "99"
    # We extract just the values (the actual option_value_ids).
    def extract_option_value_ids
      raw = params.dig(:variant, :option_value_ids)
      return [] unless raw.is_a?(ActionController::Parameters) || raw.is_a?(Hash)
      raw.values.map(&:to_i).reject(&:zero?)
    end

    def variant_params
      params.require(:variant).permit(
        :sku, :price, :stock_quantity, :weight, :is_master,
        { images: [] }
      )
    end
  end
end
