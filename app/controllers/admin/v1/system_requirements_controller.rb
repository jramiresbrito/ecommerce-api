module Admin::V1
  class SystemRequirementsController < ApiController
    before_action :set_system_requirements, only: %i[update destroy]

    def index
      @system_requirements = SystemRequirement.all
    end

    def create
      @system_requirement = SystemRequirement.new(system_requirements_params)
      save_system_requirements!
    end

    def update
      @system_requirement.attributes = system_requirements_params
      save_system_requirements!
    end

    def destroy
      @system_requirement.destroy!
    rescue StandardError
      render_error(fields: @system_requirement.errors.messages)
    end

    private

    def system_requirements_params
      return {} unless params.key?(:system_requirement)

      params.require(:system_requirement).permit(:id, :name,
                                                 :operational_system,
                                                 :storage, :processor,
                                                 :memory, :video_board)
    end

    def save_system_requirements!
      @system_requirement.save!
      render :show
    rescue StandardError
      render_error(fields: @system_requirement.errors.messages)
    end

    def set_system_requirements
      @system_requirement = SystemRequirement.find(params[:id])
    end
  end
end
