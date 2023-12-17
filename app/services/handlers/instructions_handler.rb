module Handlers
  class InstructionsHandler < BaseHandler
    attr_reader :robo_request, :robo_job

    def initialize(robo_request)
      @robo_request = robo_request
      @robo_job = robo_request.parent
    end

    def broadcast_processing_state
      ActionCable.server.broadcast(robo_job.stream_key, {
        turbo_stream: turbo_stream_action(:update,
          target: "get-instructions",
          partial: "robo_jobs/instructions/processing",
          locals: { robo_request: robo_request }
        )
      })
    end

    def handle_response
      robo_job.update(generated_instructions: JSON.parse(robo_request.response))
      robo_job.process_instructions_to_changes
    end

    def broadcast_finished_state
      ActionCable.server.broadcast(robo_job.stream_key, {
        turbo_stream: turbo_stream_action(:update,
          target: "get-instructions",
          partial: "robo_jobs/instructions/finished",
          locals: {
            robo_job: robo_job.reload,
            ding: true
          }
        )
      })
    end

    private

    def stream_key
      robo_job.stream_key
    end

    def primary_target
      "get-instructions"
    end

    def primary_label
      "Build Instructions"
    end
  end
end
