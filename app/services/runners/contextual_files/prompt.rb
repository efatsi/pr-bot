module Runners::ContextualFiles
  class Prompt < BasePromptGenerator

    def robo_job
      @robo_job ||= robo_request.parent
    end

    def prompt_messages
      [
        { role: "system", content: PromptHub::SYSTEM_SETUP },
        { role: "user", content: contextual_files_prompt },
      ]
    end

    private

    def contextual_files_prompt
      [
        project_tools,
        "",
        "What files from the Directory Tree should I review to implement the following feature request in this project?",
        "Directory Tree:",
        project.fetch_directory_tree.join("\n"),
        "",
        "Feature request:",
        robo_job.feature_request,
        "",
        "Return paths for files that would provide helpful context #{PromptHub::RETURN_AS_JSON}",
        "- files: An array of files worth investigating:",
        "  - filpath: exact path of file",
        "  - why: explain why this is relevant to the feature request",
      ].join("\n")
    end

  end
end
