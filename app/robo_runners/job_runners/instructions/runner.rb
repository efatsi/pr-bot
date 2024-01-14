module JobRunners::Instructions
  class Runner < JobRunners::BaseJobRunner

    private

    def robo_job
      @robo_job ||= robo_request.parent
    end

    def broadcast_processing_state
      broadcast(
        partial: 'robo_jobs/instructions/processing',
        locals: { robo_request: robo_request, label: primary_label }
      )
    end

    def handle_response
      robo_job.update(generated_instructions: JSON.parse(robo_request.response))
      robo_job.process_instructions_to_pending_actions
    end

    def broadcast_finished_state
      broadcast(
        partial: 'robo_jobs/instructions/finished',
        locals: {
          robo_job: robo_job.reload,
          ding: true
        }
      )
    end

    def primary_target
      "get-instructions"
    end

    def primary_label
      "Build Instructions"
    end
  end
end
