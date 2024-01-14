module JobRunners
  class BaseJobRunner < BaseRoboRunner

    private

    # Most methods defined in subclasses
    def broadcast_processing_state
    end

    def handle_response
    end

    def broadcast_finished_state
    end

    # Consistent error reporting though
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
