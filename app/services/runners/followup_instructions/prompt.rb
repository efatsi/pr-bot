module Runners::FollowupInstructions
  class Prompt < Runners::Instructions::Prompt

    # identical to Runners::Instructions::Prompt except w/ `previous_convo_messages`
    def prompt_messages
      [
        { role: "system", content: PromptHub::SYSTEM_SETUP },
        { role: "user", content: instructions_background_prompt },
        { role: "system", content: "I understand the instructions" },
        *previous_convo_messages,
        { role: "user", content: relevant_files_prompt },
        { role: "system", content: PromptHub::UNDERSTAND_FILES },
        { role: "user", content: instructions_prompt }
      ]
    end

    private

    def previous_convo_messages
      parent_job = robo_job.parent_job

      if robo_job.include_last_convo?
        last_job = parent_job.followup_jobs.to_a.reverse.detect{|a| a.actions.any?} || parent_job
        [
          { role: "user", content: last_job.feature_request },
          { role: "system", content: last_job.generated_instructions.to_s },
        ]

      elsif robo_job.include_all_convos?
        [parent_job, *parent_job.followup_jobs].flat_map do |job|
          if job.actions.any?
            [
              { role: "user", content: job.feature_request },
              { role: "system", content: job.generated_instructions.to_s },
            ]
          end
        end.compact
      end
    end
  end
end
