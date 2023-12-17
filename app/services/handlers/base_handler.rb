module Handlers
  class BaseHandler
    include ServiceStreamHelpers

    def broadcast_error_state(error)
      # relies on stream_key, primary_target, and primary_label being defined
      ActionCable.server.broadcast(stream_key, {
        turbo_stream: turbo_stream_action(:update,
          target: primary_target,
          partial: "robo_jobs/shared/error",
          locals: {
            robo_request: robo_request,
            error: error,
            label: primary_label
          }
        )
      })
    end
  end
end
