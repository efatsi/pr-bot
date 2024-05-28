module JobRunners::HighlightText
  class Runner < BaseRoboRunner

    private

    alias :robo_job :subject

    # no op for both of these, just injecting updated copy through handle_response
    def broadcast_event_scaffold
    end

    def broadcast_finished_state
    end

    def build_robo_requests
      @robo_requests = robo_job.contextual_files.pending.map do |contextual_file|
        if contextual_file.robo_reasoning.present?
          RoboRequest.create!(
            parent: contextual_file,
            robo_event: robo_event,
            robot: "gpt-3",
            request_type: robo_event.event_request_type,
            prompt_messages: prompt_message_for(contextual_file)
          )
        end
      end
    end

    def prompt_message_for(contextual_file)
      prompt = JobRunners::HighlightText::Prompt.new(
        project,
        contextual_file
      )

      prompt.generate_prompt_messages
    end

    def handle_response(robo_request)
      contextual_file = robo_request.parent

      highlighted_text = JSON.parse(robo_request.response)["formatted_text"]
      new_analysis = {explanation: highlighted_text}

      new_robo_analysis = contextual_file.robo_analysis.deep_merge(
        {robo_request.robot => new_analysis}
      )

      contextual_file.update(robo_analysis: new_robo_analysis)

      broadcast_updated_contextual_file(contextual_file)
    end

    def broadcast_updated_contextual_file(contextual_file)
      broadcast(
        partial: "robo_events/expand_contextual_files/contextual_file",
        target: "contextual-file-#{contextual_file.id}",
        action: :replace,
        locals: {
          robo_job: robo_job,
          contextual_file: contextual_file
        }
      )
    end
  end
end
