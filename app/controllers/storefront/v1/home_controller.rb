module Storefront::V1
  class HomeController < ApiController
    def index
      @loader_service = Storefront::HomeLoaderService.new
      @loader_service.call
    end
  end
end
