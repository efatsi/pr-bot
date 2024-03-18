module JobRunners::EnhanceFeatureRequest
  class Prompt < BasePromptGenerator

    alias :robo_job :subject

    def prompt_messages
      [
        { role: "user", content: PromptHub::SYSTEM_SETUP },
        { role: "system", content: PromptHub::ROGER_THAT },
        { role: "user", content: instructions_prompt },
        { role: "system", content: PromptHub::ROGER_THAT },
        { role: "user", content: robo_job_context_files },
        { role: "system", content: PromptHub::UNDERSTAND_FILES },
        *previous_convo_messages,
        { role: "user", content: final_request_prompt }
      ]
    end

    private

    def instructions_prompt
      [
        project_tools,
        "",
        "Your job is to talk about the incoming feature request and a solution plan to implement it, no code.",
        "For solutions that involves complex execution paths, take time to talk them out when explaining your reasoning.",
        "Describe the problem and solution in thorough technical detail. Don't write code.",
      ].join("\n")
    end

    def final_request_prompt
      robo_job.feature_request
    end

    def previous_convo_messages
      # TODO: implement
      []
    end
  end
end
