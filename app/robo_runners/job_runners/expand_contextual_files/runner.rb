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

      # TODO: user input to vet / change these
      # search_terms = JSON.parse(raw_response)["search_terms"][0..1]
      # process_search_terms_to_contextual_files(search_terms, robo_request)

    rescue => e
      # might not be though, capture as error
      robo_request.update(status: "error", error: e.message)
    end

    # extra private

    def process_file_list_to_contextual_files(generated_file_data, robo_request)
      generated_file_data.each do |file_data|
        filepath = file_data["filepath"]
        file_robo_analysis = {
          robo_request.robot => { why: file_data["why"] }
        }

        add_file_to_contextual_files(filepath, file_robo_analysis)
      end
    end

    def process_search_terms_to_contextual_files(search_terms, robo_request)
      search_terms.each do |term|
        project.file_content_search(query: term).each do |file_data|
          filepath = file_data[:file]
          file_reasoning = {
            robo_request.robot => { why: "This file contains the search term: ‘#{term}’" }
          }

          add_file_to_contextual_files(filepath, file_reasoning)
        end
      end
    end

    def add_file_to_contextual_files(filepath, file_robo_analysis)
      # skip seed files
      if filepath.in? robo_job.seed_contextual_files
        return
      end

      # Check for invalid filepaths or relevance < 2
      if project.invalid_path?(filepath)
        robo_job.contextual_files.create(
          filepath: filepath,
          robo_event: robo_event,
          robo_analysis: { robo_request.robot => { why: file_data["why"] } },
          status: "ignored"
        )
        return
      end

      if existing = robo_job.contextual_files.find_by(filepath: filepath)
        # add to existing file analysis
        existing.update(robo_analysis: existing.robo_analysis.merge(
          file_robo_analysis
        ))

      else
        # create new contextual file
        robo_job.contextual_files.create(
          filepath: filepath,
          robo_event: robo_event,
          robo_analysis: file_robo_analysis
        )
      end
    end
  end
end
