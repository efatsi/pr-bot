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
      ].join("\n")
    end

  end
end
