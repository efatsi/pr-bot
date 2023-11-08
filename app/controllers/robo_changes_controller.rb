class RoboChangesController < ApplicationController
  include ActionController::Live

  def execute_all
    response.headers['Content-Type'] = 'text/event-stream'
    response.headers['Last-Modified'] = Time.now.httpdate

    sse = SSE.new(response.stream, event: "message")

    robo_job.robo_changes.pending.each do |robo_change|
      robo_change.fire!

      sse.write({
        turbo_stream: turbo_stream.update(
          "robo-change-#{ robo_change.id }",
          partial: "robo_jobs/robo_change/index",
          locals: { robo_change: robo_change }
        )
      })

      sleep(0.25)
    end
  ensure
    sse.close
  end

  def execute
    robo_change.fire!

    render turbo_stream: turbo_stream.update(
      "robo-change-#{ robo_change.id }",
      partial: "robo_jobs/robo_change/index",
      locals: { robo_change: robo_change }
    )
  end

  private

  helper_method :robo_change
  def robo_change
    @robo_change ||= robo_job.robo_changes.find_by(id: params[:id])
  end

  def robo_job
    @robo_job ||= RoboJob.find_by(id: params[:robo_job_id])
  end
end
