class RoboEventsController < ApplicationController

  def create
    robo_event = RoboEvent.create!(
      subject: robo_job,
      event_type: params[:event_type],
      parent_robo_event: robo_job.last_active_event
    )

    EventConductorJob.perform_later(robo_event.id)
  end

  def destroy
    robo_event = robo_job.robo_events.find(params[:id])
    robo_event.destroy

    redirect_to robo_job_path(robo_job)
  end

  private

  def robo_job
    @robo_job ||= RoboJob.find(params[:robo_job_id])
  end
end
