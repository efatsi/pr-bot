class RoboChangesController < SseApplicationController
  before_action :set_sse_headers, only: :execute_all

  def execute_all
    pending_count = robo_job.robo_changes.pending.count
    robo_job.robo_changes.pending.each_with_index do |robo_change, i|
      robo_change.fire!

      sse.write({
        turbo_stream: turbo_stream.update(
          "robo-change-#{ robo_change.id }",
          partial: "robo_jobs/robo_changes/show",
          locals: { robo_change: robo_change }
        )
      })

      if i+1 < pending_count
        # sleep unless on the last one
        sleep(0.25)
      end
    end
  ensure
    sse.write({ turbo_stream: turbo_update_fire_all })

    sse.close
  end

  def execute
    robo_change.fire!

    stream_updates = [
      turbo_stream.update(
        "robo-change-#{ robo_change.id }",
        partial: "robo_jobs/robo_changes/show",
        locals: { robo_change: robo_change }
      ),
      turbo_update_fire_all
    ]

    render turbo_stream: stream_updates
  end

  def skip
    robo_change.update(status: 'skipped')

    render turbo_stream: [
      turbo_stream.update(
        "robo-change-#{ robo_change.id }",
        partial: "robo_jobs/robo_changes/show",
        locals: { robo_change: robo_change }
      ),
      turbo_update_fire_all
    ]
  end

  def unexecute
    robo_change.unfire!

    render turbo_stream: [
      turbo_stream.update(
        "robo-change-#{ robo_change.id }",
        partial: "robo_jobs/robo_changes/show",
        locals: { robo_change: robo_change }
      ),
      turbo_update_fire_all
    ]
  end

  def unskip
    robo_change.update(status: 'pending')

    render turbo_stream: [
      turbo_stream.update(
        "robo-change-#{ robo_change.id }",
        partial: "robo_jobs/robo_changes/show",
        locals: { robo_change: robo_change }
      ),
      turbo_update_fire_all
    ]
  end

  private

  helper_method :robo_change
  def robo_change
    @robo_change ||= robo_job.robo_changes.find_by(id: params[:id])
  end

  def robo_job
    @robo_job ||= RoboJob.find_by(id: params[:robo_job_id])
  end

  def turbo_update_fire_all
    turbo_stream.update(
        "fire-all-#{robo_job.id}",
        partial: "robo_jobs/instructions/fire_all",
        locals: { robo_job: robo_job }
      )
  end
end
