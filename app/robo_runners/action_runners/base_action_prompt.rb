module ActionRunners
  class BaseActionPrompt < BasePromptGenerator

    def prompt_messages
      [
        { role: "system", content: PromptHub::SYSTEM_SETUP },
        { role: "user", content: action_background_prompt },
        { role: "system", content: PromptHub::ROGER_THAT },
        { role: "user", content: action_context_files },
        { role: "system", content: PromptHub::UNDERSTAND_FILES },
        { role: "user", content: action_instructions_prompt }
      ]
    end

    private

    def action
      @action ||= robo_request.parent
    end

    def action_context_files
      contextual_file_data = action.relevant_files.map do |file_row|
        begin
          {
            name: file_row["file"],
            content: File.read(project.full_path(file_row["file"]))
          }
        rescue
          nil
        end.compact
      end

      [
        "These are relevant project files to work with:",
        "<contextual_file_data>",
        contextual_file_data,
        "</contextual_file_data>"
      ].join("\n")
    end

    def action_instructions_prompt
      [
        "This action is part of a broader feature request effort:",
        action.robo_job.feature_request,
        "",
        "The overview for this feature implementation is:",
        action.robo_job.generated_plan["overview"],
        "",
        "Fill in this action specification to accomplish the task:",
        JSON.pretty_generate(action.arguments_placeholder),
      ].join("\n")
    end

    def action_example_prompts
      action_examples.each_with_index.map do |example, i|
        [
          "<example-#{i+1}>",
          "#{JSON.pretty_generate(example)}",
          "</example-#{i+1}>"
        ].join("\n")
      end.join("\n\n")
    end

  end
end
