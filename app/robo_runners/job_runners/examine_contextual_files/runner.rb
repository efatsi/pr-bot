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

    def broadcast_event_scaffold
      # instead of broadcasting new scaffold, update each examined file w/ a spinner
      robo_event.robo_requests.each do |robo_request|
        contextual_file = robo_request.parent
        broadcast_processing_contextual_file(contextual_file)
      end
    end

    def handle_response(robo_request)
      contextual_file = robo_request.parent

      relevance_analysis = JSON.parse(robo_request.response)
      new_robo_analysis = contextual_file.robo_analysis.deep_merge(
        {robo_request.robot => relevance_analysis}
      )

      contextual_file = robo_request.parent
      contextual_file.update(robo_analysis: new_robo_analysis)

      broadcast_updated_contextual_file(contextual_file)
    end

    def broadcast_finished_state
      # reload the whole expand detail to get reordered list
    end

    # extra private

    def prompt_message_for(contextual_file)
      prompt = JobRunners::ExamineContextualFiles::Prompt.new(
        project,
        contextual_file
      )

      prompt.generate_prompt_messages
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

    def broadcast_processing_contextual_file(contextual_file)
      broadcast(
        partial: "robo_events/expand_contextual_files/contextual_file",
        target: "contextual-file-#{contextual_file.id}",
        action: :replace,
        locals: {
          robo_job: robo_job,
          contextual_file: contextual_file,
          is_processing: true
        }
      )
    end
  end
end
