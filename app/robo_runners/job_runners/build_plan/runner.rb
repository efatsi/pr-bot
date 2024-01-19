module JobRunners::BuildPlan
  class Runner < JobRunners::Instructions::Runner

    # similar in every way to the instructions runner except handling response & label

    private

    def handle_response
      generated_plan = JSON.parse(robo_request.response)

      robo_job.update(generated_plan: generated_plan)
      robo_job.actions.destroy_all
      process_plan_to_pre_flight_changes(generated_plan)
    end

    def primary_label
      "Build Plan"
    end

    def process_plan_to_pre_flight_changes(generated_plan)
      generated_plan["build_plan"].each do |changeset|
        action_type = changeset.delete("action")

        robo_job.actions.create!(
          type: "Actions::#{action_type.camelize}",
          status: "pre_flight",
          **changeset.slice("action", "summary", "arguments", "relevant_files")
        )
      end
    end
  end
end
