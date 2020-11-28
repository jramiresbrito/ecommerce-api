module Admin::V1
  class CategoriesController < ApiController
    def index
      @categories = Category.all
    end

    def create
      @category = Category.new(category_params)
      save_category!
    end

    private

    def category_params
      return {} unless params.key?(:category)

      params.require(:category).permit(:id, :name)
    end

    def save_category!
      @category.save!
      render :show
    rescue StandardError
      render_error(fields: @category.errors.messages)
    end
  end
end
