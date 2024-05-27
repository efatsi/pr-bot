module JobRunners::ExpandContextualFiles
  class Runner < BaseRoboRunner

    def finish
      # render the broken out files
      super

      # then, immeditialy start the next event
      next_event = RoboEvent.create!(
        event_type: "examine_contextual_files",
        subject: subject,
        parent_robo_event: robo_event
      )

      RoboConductor.new(next_event).start_event
    end

    private

    alias :robo_job :subject

    def handle_response(robo_request)
      raw_response = robo_request.response
      generated_file_data = JSON.parse(raw_response)["files"]

      process_file_list_to_contextual_files(generated_file_data, robo_request)

    rescue => e
      # might not be though, capture as error
      robo_request.update(status: "error", error: e.message)
    end

    # extra private

    def process_file_list_to_contextual_files(generated_file_data, robo_request)
      generated_file_data.each do |file_data|
        if file_data["filepath"].in? robo_job.seed_contextual_files
          # skip seed files
          next
        end

        # Check for invalid filepaths or relevance < 2
        if project.invalid_path?(file_data["filepath"])
          robo_job.contextual_files.create(
            filepath: file_data["filepath"],
            robo_event: robo_event,
            robo_analysis: { robo_request.robot => { why: file_data["why"] } },
            status: "ignored"
          )
          next
        end

        file_robo_analysis = {
          robo_request.robot => { why: file_data["why"] }
        }

        if existing = robo_job.contextual_files.find_by(filepath: file_data["filepath"])
          # add to existing file analysis
          existing.update(robo_analysis: existing.robo_analysis.merge(
            file_robo_analysis
          ))

        else
          # create new contextual file
          robo_job.contextual_files.create(
            filepath: file_data["filepath"],
            robo_event: robo_event,
            robo_analysis: file_robo_analysis
          )
        end
      end
    end
  end
end
