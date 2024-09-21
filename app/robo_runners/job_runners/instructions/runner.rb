module JobRunners::Instructions
  class Runner < BaseRoboRunner

    private

    alias :robo_job :subject

    def handle_response(robo_request)
      raw_response = robo_request.response

      # the response  _should_ be a workable JSON string
      generated_instructions = JSON.parse(robo_request.response)

      process_instructions_to_pending_actions(generated_instructions, robo_request)

    rescue => e
      # might not be though, capture as error
      robo_request.update(status: "error", error: e.message)
    end

    def process_instructions_to_pending_actions(generated_instructions, robo_request)
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

        Action.create!(
          type: "Actions::#{action_type.camelize}",
          robo_request: robo_request,
          status: "pending",
          summary: summary,
          arguments: new_arguments,
        )
      end
    end
  end
end
