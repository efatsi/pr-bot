module JobRunners::ExamineContextualFiles
  class Runner < BaseRoboRunner

    def finish
      # re-render the expand details
      super

      # then, immeditialy start the highlight event
      next_event = RoboEvent.create!(
        event_type: "highlight_text",
        subject: subject,
        parent_robo_event: robo_event
      )

      RoboConductor.new(next_event).start_event
    end

    private

    alias :robo_job :subject

    def build_robo_requests
      @robo_requests = robo_job.contextual_files.pending.map do |contextual_file|
        RoboRequest.create!(
          parent: contextual_file,
          robo_event: robo_event,
          robot: "gpt-4-mini",
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

      # <= 2 -> ignored
      # >= 4 -> accepted
      if relevance_analysis["relevance"] <= 2
        contextual_file.update(status: "ignored")
      elsif relevance_analysis["relevance"] >= 4
        contextual_file.update(status: "accepted")
      end


      contextual_file.update(robo_analysis: new_robo_analysis)

      broadcast_updated_contextual_file(contextual_file)
    end

    def broadcast_finished_state
      # fetch the parent `expand` event
      parent_event = robo_event.parent_robo_event

      # update it so files are ordered by relevance
      broadcast(
        partial: "robo_events/expand_contextual_files/details",
        target: "robo-event-details-#{parent_event.id}",
        action: :replace,
        locals: {
          robo_event: parent_event,
          open_on_load: true
        }
      )
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
