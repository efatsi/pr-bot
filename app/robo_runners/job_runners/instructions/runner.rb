module JobRunners::Instructions
  class Runner < JobRunners::BaseJobRunner

    private

    alias :robo_job :parent

    def broadcast_processing_state
      broadcast(
        partial: 'robo_jobs/instructions/processing',
        locals: { robo_request: robo_request, label: primary_label }
      )
    end

    def handle_response
      generated_instructions = JSON.parse(robo_request.response)

      robo_job.update(generated_instructions: generated_instructions)
      robo_job.actions.destroy_all
      process_instructions_to_pending_actions(generated_instructions)
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
