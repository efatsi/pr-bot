class RoboEventsController < ApplicationController

  def create
    # join available w/ cookied to ensure valid and selected robots
    selected_robots = available_robots & cookied_robots

    subject = RoboJob.find(params[:robo_job_id])

    robo_event = RoboEvent.create!(
      subject: subject,
      robots: selected_robots,
      event_type: params[:event_type],
      parent_robo_event: subject.last_active_event
    )

    RoboConductor.new(robo_event).start_event
  end

  def reset_to_here
    robo_event = RoboEvent.find(params[:id])
    robo_event.child_robo_events.destroy_all

    redirect_to robo_job_path(robo_job)
  end

  def destroy
    robo_event = RoboEvents.find(params[:id])
    robo_event.destroy

    redirect_to robo_job_path(robo_job)
  end
end
