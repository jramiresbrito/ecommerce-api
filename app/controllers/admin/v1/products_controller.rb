module Admin::V1
  class ProductsController < ApiController
    def index
      @products = set_products
    end

    private

    def set_products
      permitted = params.permit({ search: :name }, { order: {} }, :page, :length)
      Admin::ModelLoadingService.new(Product.all, permitted).call
    end
  end
end
