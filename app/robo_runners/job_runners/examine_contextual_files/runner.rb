module JobRunners::ExamineContextualFiles
  class Runner < BaseRoboRunner

    private

    alias :robo_job :subject

    def build_robo_requests
      # TODO: loop over project's files and create robo_request for each one
      #
      # @robo_requests = robo_job.contextual_files.map do |file|
      #   RoboRequest.create!(
      #     parent: subject,
      #     robo_event: robo_event,
      #     robot: "gpt-3",
      #     request_type: robo_event.request_event_type,
      #     prompt_messages: prompt_message_for(file)
      #   )
      # end
    end

    def handle_response
      # TODO: update passed in ContextualFile records with structured response
      # robo_job.all_contextual_files.each do |file|
    end

    # extra private

    def prompt_message_for(contextual_file)
      JobRunners::ExamineContextualFiles::Prompt.new(project, contextual_file)

      prompt.generate_prompt_messages
    end
  end
end
