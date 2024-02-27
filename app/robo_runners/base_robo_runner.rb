class BaseRoboRunner
  include TurboStreamHelpers

  attr_reader :robo_event, :subject, :robo_requests

  def initialize(robo_event)
    @robo_event = robo_event
    @subject = robo_event.subject
  end

  def gooo
    @robo_requests = robo_event.robots.map do |robot|
      RoboRequest.create(
        parent: subject,
        robo_event: robo_event,
        robot: robot,
        request_type: robo_event.event_type,
        prompt_messages: prompt_messages
      )
    end

    # broadcast the event scaffold with prompt and response container
    broadcast_event_scaffold

    # run LLM request
    robo_requests.each do |robo_request|
      robo_stream_proc = stream_proc(robo_request)
      response = RobotApi.new(robo_stream_proc).conversation(
        robo_request.prompt_messages,
        model: robo_request.robot
      )
      robo_request.update(response: response)
    end

    # # handle response: save the good stuff to db
    # handle_response

    # robo_event.just_finished = true

    # # broadcast finished state
    # broadcast_finished_state

  rescue => error
    if robo_requests.none? { |robo_request| robo_request.response.present? }
      robo_event.destroy
    end

    broadcast_error_state(error)
  end

  private

  def prompt_messages
    runner_module = self.class.module_parents[0]
    prompt = runner_module::Prompt.new(robo_event.project, subject)

    prompt.generate_prompt_messages
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
  end

  def broadcast_error_state(error)
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
      ActionCable.server.broadcast(robo_job.stream_key, {
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
