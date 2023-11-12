class RoboJobStreamsController < ApplicationController
  include ActionController::Live

  def get_contextual_files
    response.headers['Content-Type'] = 'text/event-stream'
    response.headers['Last-Modified'] = Time.now.httpdate

    sse = SSE.new(response.stream, event: "message")

    robo_request = robo_job.prepare_request("contextual_files")

    sse.write({
      turbo_stream: turbo_stream.update(
        "get-files",
        partial: "robo_jobs/files/processing",
        locals: { robo_request: robo_request }
      )
    })

    # proc to write to see
    sse_proc = proc do |new_chars|
      sse.write({
        turbo_stream: turbo_stream.append(
          "ai-response",
          plain: new_chars
        )
      })
    end

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

  ensure
    sse.close
  end

  def get_instructions
    response.headers['Content-Type'] = 'text/event-stream'
    response.headers['Last-Modified'] = Time.now.httpdate

    sse = SSE.new(response.stream, event: "message")

    robo_request = robo_job.prepare_request("instructions")

    sse.write({
      turbo_stream: turbo_stream.update(
        "get-instructions",
        partial: "robo_jobs/instructions/processing",
        locals: { robo_request: robo_request }
      )
    })

    # proc to write to see
    sse_proc = proc do |new_chars|
      sse.write({
        turbo_stream: turbo_stream.append(
          "ai-response",
          plain: new_chars
        )
      })
    end

    robo_job.run_request(robo_request, sse_proc)

    sse.write({
      turbo_stream: turbo_stream.update(
        "get-instructions",
        partial: "robo_jobs/instructions/finished",
        locals: { robo_job: robo_job.reload }
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
