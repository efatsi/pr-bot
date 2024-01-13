module Runners
  class BuildPlan::Runner < BaseRunner

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

    def broadcast_finished_state
      broadcast(
        target: "robo-changes",
        partial: 'robo_jobs/action_plan/index',
        locals: {
          robo_job: robo_job.parent_job.reload,
          ding: true
        }
      )
    end

    def primary_target
      "get-plan"
    end

    def primary_label
      "Build Plan"
    end
  end
end
