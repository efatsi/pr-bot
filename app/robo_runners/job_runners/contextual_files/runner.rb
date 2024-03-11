module JobRunners::ContextualFiles
  class Runner < BaseRoboRunner

    private

    alias :robo_job :subject

    def handle_response
      # robo_job.update(contextual_files: robo_job.dig_out_contextual_files(robo_request))
      # leave the robo_job alone, stash structured content on robo_request instead
    end

    def broadcast_finished_state
      # TODO: implement
    end

  end
end
