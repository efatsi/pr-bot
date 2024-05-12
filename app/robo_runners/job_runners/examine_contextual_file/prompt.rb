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
        "Return the relevance of the provided file in relation to the feature request #{PromptHub::RETURN_AS_JSON}",
        "- relevance: on a scale of 1-5, how important the file's is to the feature implementation",
        "- explanation: a brief explanation for your ranking",
      ].join("\n")
    end

  end
end
