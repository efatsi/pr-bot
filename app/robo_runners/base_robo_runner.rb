class BaseRoboRunner
  include TurboStreamHelpers

  attr_reader :robo_event, :subject, :robo_requests

  def initialize(robo_event)
    @robo_event = robo_event
    @subject = robo_event.subject

    if robo_event.robo_requests.any?
      @robo_requests = robo_event.robo_requests
    else
      build_robo_requests
    end
  end

  def gooo
    # broadcast the event scaffold with prompt and response container
    broadcast_event_scaffold

    # in background, trip the `run_request` method for each RoboRequest, queue `finish` when done
    GoodJob::Batch.enqueue(on_finish: EventFinishJob, robo_event_id: robo_event.id) do
      robo_requests.each do |robo_request|
        RequestRunnerJob.perform_later(robo_event.id, robo_request.id)
      end
    end

  rescue => error
    handle_error(error)
  end

  def run_request(robo_request)
    # Pass the prompt to the Robot, stream the response up to UI as it comes
    robo_stream_proc = stream_proc(robo_request)
    response = RobotApi.new(robo_stream_proc).conversation(
      robo_request.prompt_messages,
      model: robo_request.robot
    )

    # save the response on RoboRequest
    robo_request.update(response: response)
  end

  def finish
    # optionally pull out any structured data if necessary
    handle_response

    # set this for the ding
    robo_event.just_finished = true

    # broadcast finished state
    broadcast_finished_state

  rescue => error
    handle_error(error)
  end

  private

  def build_robo_requests
    @robo_requests = robo_event.robots.map do |robot|
      RoboRequest.create!(
        parent: subject,
        robo_event: robo_event,
        robot: robot,
        request_type: robo_event.event_type,
        prompt_messages: prompt_messages
      )
    end
  end

  def prompt_messages
    @prompt_messages ||= begin
      runner_module = self.class.module_parents[0]
      prompt = runner_module::Prompt.new(robo_event.project, subject)

      prompt.generate_prompt_messages
    end
  end

  def broadcast_event_scaffold
    broadcast(
      partial: "robo_events/scaffold",
      target: "next-steps",
      action: :replace,
      locals: {
        robo_event: robo_event,
        robo_requests: robo_requests,
      }
    )
  end

  def handle_response
    # no op by default, response is already saved to request
  end

  # this replaces the scaffold with the finished state
  def broadcast_finished_state
    broadcast(
      partial: "robo_events/list_item",
      target: "robo-event-scaffold-#{robo_event.id}",
      action: :replace,
      locals: {
        robo_event: robo_event,
        ding: true
      }
    )

    # update the parent event too since it's rendering is dependent on children
    broadcast(
      partial: "robo_events/list_item",
      target: "robo-event-#{robo_event.parent_robo_event_id}",
      action: :replace,
      locals: {
        robo_event: robo_event.parent_robo_event,
        render_just_self: true
      }
    )
  end

  def handle_error(error)
    if robo_requests && robo_requests.none? { |robo_request| robo_request.response.present? }
      robo_event.destroy
    end

    broadcast(
      partial: "shared/error_modal",
      target: "modal",
      locals: {
        robo_event: robo_event,
        robo_requests: robo_requests,
        error: error,
      }
    )
  end

  def broadcast(target:, partial: nil, locals: {}, action: :update)
    ActionCable.server.broadcast(robo_job.stream_key, {
      turbo_stream: turbo_stream_action(action,
        target: target,
        partial: partial,
        locals: locals
      )
    })
  end

  def stream_proc(robo_request)
    stream_proc_target = "ai-response-#{robo_request.id}"

    proc do |new_chars|
      ActionCable.server.broadcast(robo_request.parent.stream_key, {
        event_timestamp: {
          target: stream_proc_target,
          time: Time.now.strftime('%s%L')
        },
        turbo_stream: turbo_stream.append(
          stream_proc_target,
          plain: new_chars
        )
      })
    end
  end
end
