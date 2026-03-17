module Admin
  class ProductsController < BaseController
    before_action :set_product, only: [:show, :edit, :update, :destroy]

    def index
      authorize Product
      @products = Product.includes(:category).all
    end

    def show
      authorize @product
    end

    def new
      authorize Product
      @product = Product.new
      @product.product_specifications.build
    end

    def create
      authorize Product
      @product = Product.new(product_params)

      if @product.save
        redirect_to admin_product_path(@product), notice: "Product created successfully."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @product
    end

    def update
      authorize @product
      if @product.update(product_params)
        redirect_to admin_product_path(@product), notice: "Product updated successfully."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @product
      @product.destroy
      redirect_to admin_products_path, notice: "Product deleted successfully."
    end

    private

    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      params.require(:product).permit(
        :name, :description, :slug, :category_id, :base_price, :total_stock,
        :product_type, :active,
        :brand, :compare_at_price, :discount_percentage, :featured,
        { images: [], option_type_ids: [] },
        product_specifications_attributes: [:id, :name, :value, :_destroy]
      )
    end
  end
end
