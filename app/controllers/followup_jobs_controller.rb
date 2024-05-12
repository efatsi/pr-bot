class FollowupJobsController < ApplicationController
  def new
    followup_job = robo_job.followup_jobs.new(
      project: project,
      seed_contextual_files: robo_job.last_contextual_files
    )

    render turbo_stream: turbo_stream.update(
      "next-steps",
      partial: "robo_events/followup_instructions/input",
      locals: {
        robo_job: robo_job,
        followup_job: followup_job
      }
    )
  end

  def create
    followup_job = robo_job.followup_jobs.new(followup_job_params)

    if followup_job.save
      robo_event = RoboEvent.create!(
        event_type: "followup_instructions",
        robots: selected_robots,
        subject: followup_job,
        parent_robo_event: robo_job.last_active_event
      )

      RoboConductor.new(robo_event).start_event
    else
      render turbo_stream: turbo_stream.update(
        "followup-input",
        partial: "robo_events/followup_instructions/input",
        locals: { robo_job: robo_job, followup_job: followup_job }
      )
    end
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
    params.require(:followup_job).permit(:feature_request, :seed_contextual_files, :include_last_convo, :include_all_convos).merge(
      project: project
    )
  end
end
