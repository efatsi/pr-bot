module JobRunners::BuildPlan
  class Runner < JobRunners::Instructions::Runner

    # similar in every way to the instructions runner except for a few things

    private

    def handle_response
      robo_job.update(generated_plan: JSON.parse(robo_request.response))
      robo_job.process_plan_to_pre_flight_changes
      # todo: create pre_flight actions on robojob w/ request response
    end

    def primary_label
      "Build Plan"
    end
  end
end
