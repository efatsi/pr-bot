module Runners::BuildPlan
  class Runner < BaseRunner

    private

    def robo_job
      @robo_job ||= robo_request.parent
    end

    def broadcast_processing_state
      broadcast(
        partial: 'robo_jobs/action_plan/processing',
        locals: { robo_request: robo_request }
      )
    end

    def handle_response
      robo_job.update(generated_plan: JSON.parse(robo_request.response))
      # todo: create pre_flight actions on robojob w/ request response
    end

    def broadcast_finished_state
      broadcast(
        target: "robo-changes",
        partial: 'robo_jobs/action_plan/index',
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
      "Build Plan"
    end
  end
end
