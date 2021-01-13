module Admin::V1
  class UsersController < ApiController
    before_action :set_user, only: %i[update destroy]

    def index
      @loading_service = Admin::ModelLoadingService.new(User.all, searchable_params)
      @loading_service.call
    end

    def create
      @user = User.new(user_params)
      save_user!
    end

    def update
      @user.attributes = user_params
      save_user!
    end

    def destroy
      @user.destroy!
    rescue StandardError
      render_error(fields: @user.errors.messages)
    end

    private

    def user_params
      return {} unless params.key?(:user)

      params.require(:user).permit(:id, :name, :password, :password_confirmation, :profile)
    end

    def save_user!
      @user.save!
      render :show
    rescue StandardError
      render_error(fields: @users.errors.messages)
    end

    def set_user
      @user = User.find(params[:id])
    end

    def searchable_params
      params.permit({ search: :name }, { order: {} }, :page, :length)
    end
  end
end
