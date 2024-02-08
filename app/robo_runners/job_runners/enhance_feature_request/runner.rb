module JobRunners::EnhanceFeatureRequest
  class Runner < JobRunners::Instructions::Runner

    # similar in every way to the instructions runner except handling response & label

    def handle_response
      # no op, the raw resposne in robo_request will be used
    end

    def broadcast_finished_state
      broadcast(
        partial: 'robo_jobs/instructions/feature_prompt_selection',
        locals: {
          robo_job: robo_job.reload,
          ding: true
        }
      )
    end

    private

    def primary_label
      "Build Plan"
    end

  end
end
