module Runners
  class FollowupInstructionsRunner < BaseRunner

    private

    def robo_job
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

    def primary_target
      "continue-conversation"
    end

    def primary_label
      "Followup Instructions"
    end
  end
end
