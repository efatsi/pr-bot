class RoboEventsController < ApplicationController

  def show_next_steps
    robo_event = RoboEvent.find(params[:id])

    # depends on params[:turbo_replace]
    render turbo_stream: turbo_stream.replace(
      params[:turbo_replace],
      partial: "robo_events/next_steps",
      locals: {
        robo_event: robo_event
      }
    )
  end

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

    redirect_to robo_job_path(robo_event.subject.parent_job_or_self)
  end

  def destroy
    robo_event = RoboEvent.find(params[:id])
    robo_event.destroy

    redirect_to robo_job_path(robo_event.subject.parent_job_or_self)
  end
end
