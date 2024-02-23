class BaseRoboRunner
  include TurboStreamHelpers

  attr_reader :robo_event, :parent, :robo_request

  def initialize(robo_event, request_type)
    @robo_event = robo_event
    @parent = robo_event.subject
    @robo_request = parent.robo_requests.new(
      robo_event: robo_event,
      request_type: request_type
    )
  end

  def gooo
    # save prompt message to robo request
    robo_request.update(prompt_messages: prompt_messages)

    # broadcast the new robo_event scaffold
    broadcast_event_scaffold

    # broadcast the "stuff is happening" update
    broadcast_processing_state

    # run LLM request
    response = RobotApi.new(stream_proc).conversation(robo_request.prompt_messages)
    robo_request.update(response: response)

    # handle response: save the good stuff to db
    handle_response

    # broadcast finished state
    broadcast_finished_state

  rescue => error
    broadcast_error_state(error)
  end

  private

  def prompt_messages
    runner_module = self.class.module_parents[0]
    prompt = runner_module::Prompt.new(robo_request)

    prompt.generate_prompt_messages
  end

  # available methods, relies on `primary_target`, and `primary_label` defined in subclass
  def broadcast(target: primary_target, partial: nil, locals: {}, action: :update)
    ActionCable.server.broadcast(robo_job.stream_key, {
      turbo_stream: turbo_stream_action(action,
        target: target,
        partial: partial,
        locals: locals
      )
    })
  end

  def broadcast_event_scaffold
    broadcast(
      partial: "robo_events/scaffold",
      target: "next-steps",
      locals: {
        robo_request: robo_request,
        robo_event: robo_event,
        label: primary_label
      }
    )
  end

  # methods that need to be defined in subclasses
  def broadcast_processing_state
    raise NotImplementedError
  end

  def handle_response
    # no op by default, response is already saved to request
  end

  def broadcast_finished_state
    raise NotImplementedError
  end

  def primary_label
    raise NotImplementedError
  end

  def broadcast_error_state(error)
    broadcast(
      partial: "robo_jobs/shared/error",
      locals: {
        robo_request: robo_request,
        error: error,
        label: primary_label
      }
    )
  end

  # TODO: update this to broadcast to robo_request id, for multiple simul streams
  def stream_proc
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

  # Default this to this key, subclasses can override if need to target multiple at same time
  def stream_proc_target
    "ai-response-#{robo_request.id}"
  end

end
