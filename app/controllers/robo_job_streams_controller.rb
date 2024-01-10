class RoboJobStreamsController < SseApplicationController
  def get_contextual_files
    UniversalRunnerJob.perform_later(robo_job.to_global_id.to_s, "contextual_files")
  end

  def build_plan
    robo_manager = RoboManager.new(robo_job, "build_plan")

    sse.write({
      turbo_stream: turbo_stream.update(
        "build-plan",
        partial: "robo_jobs/build_plan/processing",
        locals: { robo_request: robo_manager.robo_request }
      )
    })

    if ROBO_ENABLED
      robo_manager.run_request(sse_proc)

      sse.write({
        turbo_stream: turbo_stream.update(
          "build-plan",
          partial: "robo_jobs/build_plan/finished",
          locals: {
            robo_job: robo_job.reload,
            ding: true
          }
        )
      })
    end

  rescue => e
    sse.write({
      turbo_stream: turbo_stream.update(
        "build-plan",
        partial: "robo_jobs/shared/error",
        locals: {
          robo_request: robo_manager&.robo_request,
          error_message: e.message,
          label: "Build Plan"
        }
      )
    })

  ensure
    sse.close
  end

  def get_instructions
    UniversalRunnerJob.perform_later(robo_job.to_global_id.to_s, "instructions")
  end

  private

  helper_method :robo_job
  def robo_job
    @robo_job ||= RoboJob.find(params[:id])
  end
end
