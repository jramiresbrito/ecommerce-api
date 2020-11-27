module Admin::V1
  class HomeController < ApiController
    def index
      render json: { ok: true }
    end
  end
end
