class FollowupJobsController < ApplicationController
  def new
    followup_job = robo_job.followup_jobs.new(contextual_files: robo_job.contextual_files)

    render turbo_stream: turbo_stream.append(
      "conversation",
      partial: "robo_jobs/instructions/followup_form",
      locals: { robo_job: robo_job, followup_job: followup_job }
    )
  end

  def create
    followup_job = robo_job.followup_jobs.new(followup_job_params)

    # TODO: do this up
    # if followup_job.save
    #   redirect_to robo_job_path(robo_job)
    # else
    #   render :new
    # end
  end

  private

  helper_method :robo_job
  def robo_job
    @robo_job ||= RoboJob.find(params[:robo_job_id])
  end

  helper_method :project
  def project
    @project ||= robo_job.project
  end

  def followup_job_params
    params.require(:followup_job).permit(:feature_request, :contextual_files)
  end
end
