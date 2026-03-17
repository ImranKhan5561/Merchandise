module Admin
  class CategoriesController < BaseController
    before_action :set_category, only: [:edit, :update, :destroy]

    def index
      authorize Category
      @categories = Category.includes(:parent).all
    end

    def new
      authorize Category
      @category = Category.new
    end

    def create
      authorize Category
      @category = Category.new(category_params)

      if @category.save
        redirect_to admin_categories_path, notice: "Category created successfully."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @category
    end

    def update
      authorize @category
      if @category.update(category_params)
        redirect_to admin_categories_path, notice: "Category updated successfully."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @category
      @category.destroy
      redirect_to admin_categories_path, notice: "Category deleted successfully."
    end

    private

    def set_category
      @category = Category.find(params[:id])
    end

    def category_params
      params.require(:category).permit(:name, :parent_id, :image)
    end
  end
end
