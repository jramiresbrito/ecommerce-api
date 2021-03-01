module Admin::V1
  class LicensesController < ApiController
    before_action :set_license, only: %i[show update destroy]

    def index
      game_licenses = License.where(game_id: params[:game_id])
      @loading_service = Admin::ModelLoadingService.new(game_licenses, searchable_params)
      @loading_service.call
    end

    def create
      @license = License.new(game_id: params[:game_id])
      @license.attributes = license_params
      save_license!
    end

    def show; end

    def update
      @license.attributes = license_params
      save_license!
    end

    def destroy
      @license.destroy!
    rescue StandardError
      render_error(fields: @license.errors.messages)
    end

    private

    def set_license
      @license = License.find(params[:id])
    end

    def searchable_params
      params.permit({ search: {} }, { order: {} }, :page, :length)
    end

    def license_params
      return {} unless params.key?(:license)

      params.require(:license).permit(:key, :platform, :status)
    end

    def save_license!
      @license.save!
      render :show
    rescue StandardError
      render_error(fields: @license.errors.messages)
    end
  end
end
