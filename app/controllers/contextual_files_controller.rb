class ContextualFilesController < ApplicationController
  def accept
    contextual_file.update(status: "accepted")
    refresh_event_details
  end

  def ignore
    contextual_file.update(status: "ignored")
    refresh_event_details
  end

  def reset
    contextual_file.update(status: "pending")
    refresh_event_details
  end

  private

  def refresh_event_details
    robo_event = contextual_file.robo_event

    render turbo_stream: [
      turbo_stream.update(
        "robo-event-details-#{robo_event.id}",
        partial: "robo_events/expand_contextual_files/details",
        locals: {
          robo_event: robo_event,
          open_on_load: true
        }
      ),
      turbo_stream.update(
        "next-steps-#{robo_event.id}",
        partial: "robo_events/expand_contextual_files/next_steps",
        locals: { robo_event: robo_event }
      )
    ]
  end

  def contextual_file
    @contextual_file ||= robo_job.contextual_files.find(params[:id])
  end

  def robo_job
    @robo_job ||= RoboJob.find(params[:robo_job_id])
  end
end
