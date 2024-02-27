module JobRunners::ContextualFiles
  class Prompt < BasePromptGenerator

    alias :robo_job :subject

    def prompt_messages
      [
        { role: "user", content: PromptHub::SYSTEM_SETUP },
        { role: "system", content: PromptHub::ROGER_THAT },
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
