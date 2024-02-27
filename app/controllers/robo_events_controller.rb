class RoboEventsController < ApplicationController

  def create
    # join available w/ cookied to ensure valid and selected robots
    selected_robots = available_robots & cookied_robots

    robo_event = RoboEvent.create!(
      subject: robo_job,
      robots: selected_robots,
      event_type: params[:event_type],
      parent_robo_event: robo_job.last_active_event
    )

    RoboConductor.new(robo_event).start_request
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
