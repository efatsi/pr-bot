module JobRunners::ContextualFiles
  class Runner < BaseRoboRunner

    alias :robo_job :parent

    private

    def handle_response
      robo_job.update(contextual_files: robo_job.dig_out_contextual_files(robo_request))
    end

    def broadcast_finished_state
      broadcast(
        partial: 'robo_jobs/files/finished',
        locals: {
          robo_job: robo_job.reload,
          robo_request: robo_request,
          ding: true,
          open_on_load: true
        }
      )
      broadcast(
        target: "get-instructions",
        partial: "robo_jobs/instructions/index",
        locals: { robo_job: robo_job }
      )
    end

    def primary_target
      "get-files"
    end

    def primary_label
      "Contextual Files"
    end
  end
end
