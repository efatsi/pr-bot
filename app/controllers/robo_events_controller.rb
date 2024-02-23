class RoboEventsController < ApplicationController

  def destroy
    robo_job = RoboJob.find(params[:robo_job_id])
    robo_event = robo_job.robo_events.find(params[:id])

    robo_event.destroy

    redirect_to robo_job_path(robo_job)
  end
end
