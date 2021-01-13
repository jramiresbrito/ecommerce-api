module Admin::V1
  class CouponsController < ApiController
    before_action :set_coupon, only: %i[update destroy]

    def index
      @loading_service = Admin::ModelLoadingService.new(Coupon.all, searchable_params)
      @loading_service.call
    end

    def create
      @coupon = Coupon.new(coupon_params)
      save_coupon!
    end

    def update
      @coupon.attributes = coupon_params
      save_coupon!
    end

    def destroy
      @coupon.destroy!
    rescue StandardError
      render_error(fields: @coupon.errors.messages)
    end

    private

    def coupon_params
      return {} unless params.key?(:coupon)

      params.require(:coupon).permit(:name,
                                     :code,
                                     :status,
                                     :discount_value,
                                     :max_use,
                                     :due_date)
    end

    def save_coupon!
      @coupon.save!
      render :show
    rescue StandardError
      render_error(fields: @coupon.errors.messages)
    end

    def set_coupon
      @coupon = Coupon.find(params[:id])
    end

    def searchable_params
      params.permit({ search: :name }, { order: {} }, :page, :length)
    end
  end
end
