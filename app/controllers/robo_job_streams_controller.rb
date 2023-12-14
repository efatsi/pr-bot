class RoboJobStreamsController < SseApplicationController
  # Toggle this off to disable fetches to the AI API
  ROBO_ENABLED = true

  before_action :set_sse_headers

  def get_contextual_files
    robo_manager = RoboManager.new(robo_job, "contextual_files")

    sse.write({
      turbo_stream: turbo_stream.update(
        "get-files",
        partial: "robo_jobs/files/processing",
        locals: { robo_request: robo_manager.robo_request }
      )
    })

    if ROBO_ENABLED
      robo_manager.run_request(sse_proc)

      sse.write({
        turbo_stream: [
          turbo_stream.update(
            "get-files",
            partial: "robo_jobs/files/finished",
            locals: {
              robo_job: robo_job.reload,
              robo_request: robo_manager.robo_request,
              open_on_load: true
            }
          ),
          turbo_stream.update(
            "get-instructions",
            partial: "robo_jobs/instructions/index",
            locals: { robo_job: robo_job }
          )
        ]
      })
    end

  rescue => e
    sse.write({
      turbo_stream: turbo_stream.update(
        "get-files",
        partial: "robo_jobs/shared/error",
        locals: {
          robo_request: robo_manager&.robo_request,
          error_message: e.message,
          label: "Contextual Files"
        }
      )
    })

  ensure
    sse.close
  end

  def get_instructions
    robo_manager = RoboManager.new(robo_job, "instructions")

    sse.write({
      turbo_stream: turbo_stream.update(
        "get-instructions",
        partial: "robo_jobs/instructions/processing",
        locals: { robo_request: robo_manager.robo_request }
      )
    })

    if ROBO_ENABLED
      robo_manager.run_request(sse_proc)

      sse.write({
        turbo_stream: turbo_stream.update(
          "get-instructions",
          partial: "robo_jobs/instructions/finished",
          locals: { robo_job: robo_job.reload }
        )
      })
    end

  rescue => e
    sse.write({
      turbo_stream: turbo_stream.update(
        "get-instructions",
        partial: "robo_jobs/shared/error",
        locals: {
          robo_request: robo_manager&.robo_request,
          error_message: e.message,
          label: "Build Instructions"
        }
      )
    })

  ensure
    sse.close
  end

  def get_followup_instructions
    # just to avoid confusion
    followup_job = robo_job

    robo_manager = RoboManager.new(followup_job, "instructions")

    sse.write({
      turbo_stream: turbo_stream.update(
        "continue-conversation",
        partial: "robo_jobs/followup/processing",
        locals: { robo_request: robo_manager.robo_request }
      )
    })

    if ROBO_ENABLED
      robo_manager.run_request(sse_proc)
      parent_job = followup_job.parent_job.reload

      sse.write({
        turbo_stream: [
          turbo_stream.update(
            "robo-changes",
            partial: "robo_jobs/instructions/robo_changes",
            locals: { robo_job: parent_job }
          ),
          turbo_stream.update(
            "continue-conversation",
            plain: ""
          )
        ]
      })
    else
      sse_proc.call("This is a test message")
      sleep(0.5)
      sse_proc.call("\nFlip ROBO_ENABLED to true to see the real thing!")
    end

  rescue => e
    sse.write({
      turbo_stream: turbo_stream.update(
        "continue-conversation",
        partial: "robo_jobs/shared/error",
        locals: {
          robo_request: robo_manager&.robo_request,
          error_message: e.message,
          label: "Continue Conversation"
        }
      )
    })

  ensure
    sse.close
  end

  private

  helper_method :robo_job
  def robo_job
    @robo_job ||= RoboJob.find(params[:id])
  end
end
