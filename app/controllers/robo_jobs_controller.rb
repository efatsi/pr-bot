class RoboJobsController < ApplicationController
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
  end

  def edit
  end

  def update
    if robo_job.update(robo_job_params)
      redirect_to robo_job_path(robo_job), notice: 'RoboJob was successfully updated.'
    else
      render :edit
    end
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
    params.require(:robo_job).permit(:feature_request, :project_id)
  end
end
