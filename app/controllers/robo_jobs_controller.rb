class RoboJobsController < ApplicationController
  after_action :clear_show_files, only: [:show]

  def new
    @robo_job = RoboJob.new(project_id: params[:project_id])
  end

  def create
    @robo_job = RoboJob.new(robo_job_params)

    if robo_job.save
      robo_job.robo_events.create(event_type: "start")

      redirect_to robo_job_path(robo_job)
    else
      render :new
    end
  end

  def show
    if robo_job.parent_job
      redirect_to robo_job_path(robo_job.parent_job)
    end
  end

  def edit_feature_and_files
  end

  def update
    file_params = params.require(:robo_job).permit(:feature_request, :seed_contextual_files, image_uploads_attributes: [:image])
    # remove image_uploads_attributes if no image is present
    file_params[:image_uploads_attributes]&.delete_if { |_, v| v[:image].blank? }

    robo_job.update(file_params)

    render turbo_stream: turbo_stream.update(
      "robo-job-start",
      partial: "robo_events/start/details",
      locals: { robo_event: robo_job.start_event, open_on_load: true }
    )
  end

  private

  helper_method :robo_job
  def robo_job
    @robo_job ||= RoboJob.find(params[:id])
  end

  helper_method :project
  def project
    @project ||= robo_job.project
  end

  def robo_job_params
    params.require(:robo_job).permit(:feature_request, :project_id, :seed_contextual_files)
  end

  def clear_show_files
    session[:show_files] = nil
  end
end
