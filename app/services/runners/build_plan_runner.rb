module Runners
  class BuildPlanRunner < BaseRunner
    attr_reader :robo_job

    def initialize(robo_request)
      super
      @robo_job = robo_request.parent
    end

    def prompt_messages
      [
        { role: "system", content: PromptHub::SYSTEM_SETUP },
        { role: "user", content: build_plan_background_prompt },
        *previous_convo_messages,
        { role: "user", content: relevant_files_prompt },
        { role: "user", content: instructions_prompt }
      ]
    end

    def broadcast_processing_state
      broadcast(
        partial: 'robo_jobs/action_plan/processing',
        locals: { robo_request: robo_request }
      )
    end

    def handle_response
      # todo: create pre_flight actions on robojob w/ request response

      # old implementation:
      # robo_job.update(generated_instructions: JSON.parse(robo_request.response))
      # robo_job.process_instructions_to_changes
    end

    def broadcast_finished_state
      broadcast(
        target: "robo-changes",
        partial: 'robo_jobs/action_plan/index',
        locals: {
          robo_job: robo_job.parent_job.reload,
          ding: true
        }
      )
    end

    private

    def stream_key
      robo_job.parent_job.stream_key
    end

    def primary_target
      "continue-conversation"
    end

    def primary_label
      "Followup Instructions"
    end
  end
end
