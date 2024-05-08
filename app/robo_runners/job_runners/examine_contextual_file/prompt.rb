module JobRunners::ExamineContextualFile
  class Prompt < BasePromptGenerator

    alias :contextual_file :subject

    def prompt_messages
      [
        { role: "user", content: PromptHub::SYSTEM_SETUP },
        { role: "system", content: PromptHub::ROGER_THAT },
        { role: "user", content: examine_file_prompt },
      ]
    end

    private

    def examine_file_prompt
      [
        project_tools(solutioning: false),
        "",
        # TODO: update all this to ask about the file
        # request JSON back w/ ranking & explanation
        #
        # "What files from the Directory Tree should I review to implement the following feature request in this project?",
        # "Directory Tree:",
        # project.fetch_directory_tree.join("\n"),
        # "",
        # "Feature request:",
        # robo_job.feature_request,
        # "",
        # "Return paths for files that would provide helpful context #{PromptHub::RETURN_AS_JSON}",
        # "- files: An array of files worth investigating:",
        # "  - filpath: exact path of file",
        # "  - why: explain why this is relevant to the feature request",
      ].join("\n")
    end

  end
end
