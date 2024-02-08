module JobRunners::BuildPlan
  class Prompt < BasePromptGenerator

    alias :robo_job :parent

    def prompt_messages
      [
        { role: "user", content: PromptHub::SYSTEM_SETUP },
        { role: "system", content: PromptHub::ROGER_THAT },
        { role: "user", content: build_plan_background_prompt },
        { role: "system", content: PromptHub::ROGER_THAT },
        *previous_convo_messages,
        { role: "user", content: robo_job_context_files },
        { role: "system", content: PromptHub::UNDERSTAND_FILES },
        { role: "user", content: instructions_prompt }
      ]
    end

    private

    def build_plan_background_prompt
      [
        project_tools,
        "",
        "Your job is to talk about the incoming feature request and a solution plan to implement it.",
        "For code that involves complex execution paths, take time to talk them out when explaining your solution.",
        "It's alright to show high level code snippets but don't worry about the fine details right now, we're focused on the big picture."
        "Describe the problem and solution in thorough technical detail.",
      ].join("\n")
    end

    def instructions_prompt
      [
        "How would you implement this feature request?",
        robo_job.feature_request,
      ].join("\n")
    end

    def previous_convo_messages
      # TODO: implement
      []
    end
  end
end
