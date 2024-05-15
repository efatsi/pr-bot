module JobRunners::ExamineContextualFiles
  class Runner < BaseRoboRunner

    private

    alias :robo_job :subject

    def build_robo_requests
      @robo_requests = robo_job.contextual_files.pending.map do |contextual_file|
        RoboRequest.create!(
          parent: contextual_file,
          robo_event: robo_event,
          robot: "gpt-3",  # or "gemini" here?
          request_type: robo_event.event_request_type,
          prompt_messages: prompt_message_for(contextual_file)
        )
      end
    end

    def handle_response
      robo_requests.each do |robo_request|
        raw_response = robo_request.response

        begin
          contextual_file = robo_request.parent

          new_robo_analysis = contextual_file.robo_analysis.deep_merge(
            {robo_request.robot => JSON.parse(raw_response)}
          )
          contextual_file.update(robo_analysis: new_robo_analysis)
        rescue => e
          # might not be though, capture as error
          robo_request.update(status: "error", error: e.message)
        end
      end
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
