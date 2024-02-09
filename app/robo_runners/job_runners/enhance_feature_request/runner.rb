module JobRunners::EnhanceFeatureRequest
  class Runner < JobRunners::Instructions::Runner

    # similar in every way to the instructions runner except handling response & label

    def handle_response
      # no op, the raw response in robo_request will be used
    end

    def broadcast_finished_state
      broadcast(
        partial: 'robo_jobs/instructions/enhance_feature_prompt',
        locals: {
          robo_job: robo_job.reload,
          open_on_load: true,
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
