module JobRunners::ExamineContextualFiles
  class Runner < BaseRoboRunner

    private

    alias :robo_job :subject

    def build_robo_requests
      @robo_requests = robo_job.contextual_files.pending.map do |contextual_file|
        RoboRequest.create!(
          parent: robo_job,
          robo_event: robo_event,
          robot: "gpt-3",  # or "gemini" here?
          request_type: robo_event.event_request_type,
          prompt_messages: prompt_message_for(contextual_file)
        )
      end
    end

    def handle_response
      # TODO: update passed in ContextualFile records with structured response
      # robo_job.all_contextual_files.each do |file|
    end

    # extra private

    def prompt_message_for(contextual_file)
      prompt = JobRunners::ExamineContextualFiles::Prompt.new(
        project,
        contextual_file
      )

      prompt.generate_prompt_messages
    end
  end
end
