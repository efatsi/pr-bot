module Handlers
  class BaseHandler
    include ServiceStreamHelpers

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
  end
end
