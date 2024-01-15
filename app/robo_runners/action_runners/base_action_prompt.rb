module ActionRunners
  class BaseActionPrompt < BasePromptGenerator

    def action
      @action ||= robo_request.parent
    end

    def action_context_files
      contextual_file_data = action.relevant_files.map do |file_row|
        {
          name: file_row["file"],
          content: File.read(project.full_path(file_row["file"]))
        }
      end

      [
        "These are relevant project files to work with:",
        "<contextual_file_data>",
        contextual_file_data,
        "</contextual_file_data>"
      ].join("\n")
    end
  end
end
