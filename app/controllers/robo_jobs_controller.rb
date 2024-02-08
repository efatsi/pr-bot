class RoboJobsController < ApplicationController
  after_action :clear_show_files, only: [:show]

  def new
    @robo_job = RoboJob.new
  end

  def create
    @robo_job = RoboJob.new(robo_job_params)

    if robo_job.save
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

  def edit
  end

  def update
    if robo_job.update(robo_job_params)
      if robo_job_params[:contextual_files].present?
        session[:show_files] = true
      end

      redirect_to robo_job_path(robo_job)
    else
      render :edit
    end
  end

  # a path that can be hit to load data into a modal about the job
  def info
  end

  def update_files
    file_params = params.require(:robo_job).permit(:contextual_files)
    robo_job.update(file_params)

    render turbo_stream: turbo_stream.update(
      "files-and-form",
      partial: "robo_jobs/files/files_and_form",
      locals: { robo_job: robo_job }
    )
  end

  def get_contextual_files
    ConductorJob.perform_later(robo_job.to_global_id.to_s, "contextual_files")
  end

  def enhance_feature_request
    ConductorJob.perform_later(robo_job.to_global_id.to_s, "enhance_feature_request")
  end

  def get_instructions
    ConductorJob.perform_later(robo_job.to_global_id.to_s, "instructions")
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
    params.require(:robo_job).permit(:feature_request, :project_id, :contextual_files)
  end

  def clear_show_files
    session[:show_files] = nil
  end
end
