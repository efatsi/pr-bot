class RoboEventsController < ApplicationController

  def create
    subject = RoboJob.find(params[:robo_job_id])

    robo_event = RoboEvent.create!(
      event_type: params[:event_type],
      robots: selected_robots,
      subject: subject,
      parent_robo_event: subject.last_active_event
    )

    RoboConductor.new(robo_event).start_event
  end

  def new_retry
    event_to_retry = RoboEvent.find(params[:id])

    if event_to_retry.is_instruction_event?
      new_event = create_instructions_retry_event(event_to_retry)
    else
      raise "Unsupported event type: #{event_to_retry.event_type}"
    end

    # # replace the event to retry with the new multi-event UI
    render turbo_stream: turbo_stream.replace(
      "robo-event-#{event_to_retry.id}",
      partial: "robo_events/list_item",
      locals: {
        robo_event: new_event
      }
    )
  end

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

  def reset_to_here
    robo_event = RoboEvent.find(params[:id])
    robo_event.child_robo_events.destroy_all

    redirect_to robo_job_path(robo_event.robo_job)
  end

  def destroy
    robo_event = RoboEvent.find(params[:id])
    robo_event.destroy

    redirect_to robo_job_path(robo_event.robo_job)
  end

  def show_sibling
    sibling_event = RoboEvent.find(params[:id])

    render turbo_stream: turbo_stream.replace(
      "robo-event-#{params[:current_event_id]}",
      partial: "robo_events/list_item",
      locals: { robo_event: sibling_event }
    )
  end

  private

  def create_instructions_retry_event(event_to_retry)
    job_to_retry = event_to_retry.subject
    parent_job = job_to_retry.parent_job_or_self

    followup_job = parent_job.followup_jobs.create!(
      project: job_to_retry.project,
      seed_contextual_files: job_to_retry.final_contextual_files,
      include_last_convo: job_to_retry.includes_past_convo?,
      include_all_convos: job_to_retry.includes_past_convo?,
      feature_request: job_to_retry.feature_request,
      images: job_to_retry.images
    )

    robo_event = RoboEvent.create!(
      event_type: "followup_instructions",
      robots: selected_robots,
      subject: followup_job,
      parent_robo_event: event_to_retry.parent_robo_event
    )
  end
end
