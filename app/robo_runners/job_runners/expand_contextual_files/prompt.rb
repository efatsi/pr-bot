module JobRunners::ExpandContextualFiles
  class Prompt < BasePromptGenerator

    alias :robo_job :subject

    def prompt_messages
      [
        { role: "user", content: PromptHub::SYSTEM_SETUP },
        { role: "system", content: PromptHub::ROGER_THAT },
        { role: "user", content: robo_job_context_files(solutioning: false) },
        { role: "system", content: PromptHub::UNDERSTAND_FILES_FOR_SEARCH },
        { role: "user", content: contextual_files_prompt },
      ]
    end

    private

    def contextual_files_prompt
      [
        "What files from the Directory Tree should I review to implement the following feature request in this project?",
        "Directory Tree:",
        project.fetch_directory_tree.join("\n"),
        "",
        "Feature request:",
        robo_job.enhanced_feature_request,
        "",
        "Return paths for files and search terms that would provide helpful context #{PromptHub::RETURN_AS_JSON}",
        "- files: An array of files worth investigating:",
        "  - filpath: exact path of file",
        "  - why: explain why this is relevant to the feature request",
        "- search_terms: 2 or 3 search terms that will surface directly related files",
      ].join("\n")
    end

  end
end
