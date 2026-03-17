module Admin
  class VariantImageSetsController < BaseController
    before_action :set_product
    before_action :set_image_set, only: [:update, :destroy]

    def create
      authorize VariantImageSet
      option_value_id = params[:option_value_id]
      
      # Create image set for this option value
      @image_set = VariantImageSet.for_values(@product, [option_value_id])
      
      if @image_set && params[:images].present?
        @image_set.images.attach(params[:images])
        redirect_to admin_product_variants_path(@product), notice: "Images uploaded successfully."
      else
        redirect_to admin_product_variants_path(@product), alert: "Failed to upload images."
      end
    end

    def update
      authorize @image_set
      
      if params[:images].present?
        @image_set.images.attach(params[:images])
      end
      
      redirect_to admin_product_variants_path(@product), notice: "Images updated successfully."
    end

    def destroy
      authorize @image_set
      @image_set.images.purge
      @image_set.destroy
      redirect_to admin_product_variants_path(@product), notice: "Image set deleted."
    end

    private

    def set_product
      @product = Product.find(params[:product_id])
    end

    def set_image_set
      @image_set = @product.variant_image_sets.find(params[:id])
    end
  end
end
