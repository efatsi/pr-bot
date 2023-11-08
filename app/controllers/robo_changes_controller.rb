class RoboChangesController < ApplicationController
  def execute_all
    robo_job.robo_changes.pending.each(&:fire)

    redirect_to robo_job_path(robo_job)

    # TODO: turbo update the robo_changes
  end

  def execute
    robo_change.fire!

    render turbo_stream: turbo_stream.update(
      "robo-change-#{ robo_change.id }",
      partial: "robo_jobs/robo_change/index",
      locals: { robo_change: robo_change }
    )
  end

  private

  helper_method :robo_change
  def robo_change
    @robo_change ||= robo_job.robo_changes.find_by(id: params[:id])
  end

  def robo_job
    @robo_job ||= RoboJob.find_by(id: params[:robo_job_id])
  end
end
