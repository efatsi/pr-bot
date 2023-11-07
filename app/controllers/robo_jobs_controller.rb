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

  private

  helper_method :robo_job
  def robo_job
    @robo_job ||= RoboJob.find(params[:id])
  end

  def robo_job_params
    params.require(:robo_job).permit(:filepath, :feature_request, :project_context)
  end
end
