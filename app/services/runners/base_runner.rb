module Runners
  class BaseRunner
    include ServiceStreamHelpers

    attr_reader :robo_request, :stream_proc

    def initialize(robo_request, stream_proc)
      @robo_request = robo_request
      @stream_proc = stream_proc
    end

    def gooo
      # save prompt message to robo request
      robo_request.update(prompt_messages: prompt_messages)

      # broadcast the "stuff is happening" update
      broadcast_processing_state

      # run LLM request
      response = robot_api.ask_gpt4(robo_request.prompt_messages, stream_proc)
      robo_request.update(response: response)

      # handle response: save the good stuff to db
      handle_response

      # broadcast finished state
      broadcast_finished_state

    rescue => error
      broadcast_error_state(error)
    end

    private

    # available methods, relies on `stream_key`, `primary_target`, and `primary_label`
    # being defined in subclass
    def broadcast(partial:, locals: {}, target: primary_target, action: :update)
      ActionCable.server.broadcast(stream_key, {
        turbo_stream: turbo_stream_action(action,
          target: target,
          partial: partial,
          locals: locals
        )
      })
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

    # methods that need to be defined in subclasses
    def broadcast_processing_state
      raise NotImplementedError
    end

    def handle_response
      raise NotImplementedError
    end

    def broadcast_finished_state
      raise NotImplementedError
    end

    def stream_key
      raise NotImplementedError
    end

    def primary_target
      raise NotImplementedError
    end

    def primary_label
      raise NotImplementedError
    end

  end
end
