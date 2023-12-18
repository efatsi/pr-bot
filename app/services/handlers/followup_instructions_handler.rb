module Handlers
  class FollowupInstructionsHandler < BaseHandler
    attr_reader :robo_request, :robo_job

    def initialize(robo_request)
      @robo_request = robo_request
      @robo_job = robo_request.parent
    end

    def broadcast_processing_state
      broadcast(
        partial: 'robo_jobs/followup/processing',
        locals: { robo_request: robo_request }
      )
    end

    def handle_response
      robo_job.update(generated_instructions: JSON.parse(robo_request.response))
      robo_job.process_instructions_to_changes
    end

    def broadcast_finished_state
      broadcast(
        target: "robo-changes",
        partial: 'robo_jobs/instructions/robo_changes',
        locals: {
          robo_job: robo_job.parent_job.reload,
          ding: true
        }
      )
    end

    private

    def stream_key
      robo_job.parent_job.stream_key
    end

    def primary_target
      "continue-conversation"
    end

    def primary_label
      "Followup Instructions"
    end
  end
end
