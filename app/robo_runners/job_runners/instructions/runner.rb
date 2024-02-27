module JobRunners::Instructions
  class Runner < BaseRoboRunner

    private

    alias :robo_job :subject

    def handle_response
      generated_instructions = JSON.parse(robo_request.response.gsub("^```\w*$", ""))

      robo_job.update(generated_instructions: generated_instructions)
      robo_job.actions.destroy_all
      process_instructions_to_pending_actions(generated_instructions)
    end

    def process_instructions_to_pending_actions(generated_instructions)
      generated_instructions["changes"].each do |changeset|
        action_type = changeset["action"]
        summary = changeset["summary"]

        new_arguments = changeset.slice("file", "new_file", "original_content", "new_content")

        # clean up the argument values
        if [".rb", ".erb"].any? { |ext| new_arguments.dig("file")&.end_with?(ext) }
          new_arguments.each do |k, v|
            new_arguments[k] = LlmCleaner.clean_ruby_text(v)
          end
        end

        robo_job.actions.create!(
          type: "Actions::#{action_type.camelize}",
          status: "pending",
          summary: summary,
          arguments: new_arguments,
        )
      end
    end
  end
end
