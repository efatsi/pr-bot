module Runners::BuildPlan
  class Runner < Runners::Instructions::Runner

    # similar in every way to the instructions runner except for a few things

    private

    def handle_response
      # robo_job.update(generated_plan: JSON.parse(robo_request.response))
      # todo: create pre_flight actions on robojob w/ request response
    end

    def primary_label
      "Build Plan"
    end
  end
end
