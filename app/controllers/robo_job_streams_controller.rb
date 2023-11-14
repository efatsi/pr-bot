class RoboJobStreamsController < ApplicationController
  include ActionController::Live

  before_action :set_headers

  # Toggle this off to disable fetches to the AI API
  ROBO_ENABLED = false

  def get_contextual_files
    robo_request = robo_job.prepare_request("contextual_files")

    sse.write({
      turbo_stream: turbo_stream.update(
        "get-files",
        partial: "robo_jobs/files/processing",
        locals: { robo_request: robo_request }
      )
    })

    if ROBO_ENABLED
      robo_job.run_request(robo_request, sse_proc)

      sse.write({
        turbo_stream: [
          turbo_stream.update(
            "get-files",
            partial: "robo_jobs/files/finished",
            locals: {
              robo_job: robo_job.reload,
              robo_request: robo_request.reload,
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

  ensure
    sse.close
  end

  def get_instructions
    robo_request = robo_job.prepare_request("instructions")

    sse.write({
      turbo_stream: turbo_stream.update(
        "get-instructions",
        partial: "robo_jobs/instructions/processing",
        locals: { robo_request: robo_request }
      )
    })

    if ROBO_ENABLED
      robo_job.run_request(robo_request, sse_proc)

      sse.write({
        turbo_stream: turbo_stream.update(
          "get-instructions",
          partial: "robo_jobs/instructions/finished",
          locals: { robo_job: robo_job.reload }
        )
      })
    end

  ensure
    sse.close
  end

  def get_followup_instructions
    robo_request = robo_job.prepare_request("instructions")

    sse.write({
      turbo_stream: turbo_stream.update(
        "followup-job",
        partial: "robo_jobs/followup/processing",
        locals: { robo_request: robo_request }
      )
    })

    if ROBO_ENABLED
      robo_job.run_request(robo_request, sse_proc)

      sse.write({
        turbo_stream: [
          turbo_stream.update(
            "conversation",
            partial: "robo_jobs/instructions/conversation",
            locals: { robo_job: robo_job.reload }
          ),
          turbo_stream.append(
            "robo-changes",
            partial: "robo_jobs/instructions/robo_changes",
            locals: { robo_job: robo_job }
          )
        ]
      })
    else
      sse_proc.call("This is a test message")
      sleep(0.5)
      sse_proc.call("\nFlip ROBO_ENABLED to true to see the real thing!")
    end
  end

  private

  attr_reader :sse

  def set_headers
    response.headers['Content-Type'] = 'text/event-stream'
    response.headers['Last-Modified'] = Time.now.httpdate
  end

  def sse
    @sse ||= SSE.new(response.stream, event: "message")
  end

  def sse_proc
    return proc do |new_chars|
      sse.write({
        turbo_stream: turbo_stream.append(
          "ai-response",
          plain: new_chars
        )
      })
    end
  end

  helper_method :robo_job
  def robo_job
    @robo_job ||= RoboJob.find(params[:id])
  end
end
