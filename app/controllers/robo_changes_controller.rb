class RoboChangesController < ApplicationController
  include ActionController::Live

  def execute_all
    response.headers['Content-Type'] = 'text/event-stream'
    response.headers['Last-Modified'] = Time.now.httpdate

    sse = SSE.new(response.stream, event: "message")

    pending_count = robo_job.all_robo_changes.pending.count
    robo_job.all_robo_changes.pending.each_with_index do |robo_change, i|
      robo_change.fire!

      sse.write({
        turbo_stream: turbo_stream.update(
          "robo-change-#{ robo_change.id }",
          partial: "robo_jobs/robo_change/show",
          locals: { robo_change: robo_change }
        )
      })

      if i+1 < pending_count
        # sleep unless on the last one
        sleep(0.25)
      end
    end
  ensure
    if robo_job.all_robo_changes.pending.none?
      sse.write({
        turbo_stream: turbo_stream.remove("fire-all")
      })
    end

    sse.close
  end

  def execute
    robo_change.fire!

    render turbo_stream: turbo_stream.update(
      "robo-change-#{ robo_change.id }",
      partial: "robo_jobs/robo_change/show",
      locals: { robo_change: robo_change }
    )
  end

  def skip
    robo_change.update(status: 'skipped')

    render turbo_stream: turbo_stream.update(
      "robo-change-#{ robo_change.id }",
      partial: "robo_jobs/robo_change/show",
      locals: { robo_change: robo_change }
    )
  end

  def unexecute
    robo_change.unfire!

    render turbo_stream: turbo_stream.update(
      "robo-change-#{ robo_change.id }",
      partial: "robo_jobs/robo_change/show",
      locals: { robo_change: robo_change }
    )
  end

  def unskip
    robo_change.update(status: 'pending')

    render turbo_stream: turbo_stream.update(
      "robo-change-#{ robo_change.id }",
      partial: "robo_jobs/robo_change/show",
      locals: { robo_change: robo_change }
    )
  end

  private

  helper_method :robo_change
  def robo_change
    @robo_change ||= robo_job.all_robo_changes.find_by(id: params[:id])
  end

  def robo_job
    @robo_job ||= RoboJob.find_by(id: params[:robo_job_id])
  end
end
