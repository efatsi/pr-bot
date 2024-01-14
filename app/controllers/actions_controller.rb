class ActionsController < SseApplicationController
  before_action :set_sse_headers, only: :execute_all

  def execute_all
    pending_count = robo_job.actions.pending.count
    robo_job.actions.pending.each_with_index do |action, i|
      action.fire!

      sse.write({
        turbo_stream: turbo_stream.update(
          "action-#{ action.id }",
          partial: "actions/show",
          locals: { action: action }
        )
      })

      if i+1 < pending_count
        # sleep unless on the last one
        sleep(0.25)
      end
    end
  ensure
    sse.write({
      turbo_stream: [
        turbo_update_fire_all,
        turbo_update_commit_button
      ]
    })

    sse.close
  end

  def execute
    action.fire!

    stream_updates = [
      turbo_stream.update(
        "action-#{ action.id }",
        partial: "actions/show",
        locals: { action: action }
      ),
      turbo_update_fire_all,
      turbo_update_commit_button
    ]
    render turbo_stream: stream_updates
  end

  def reset
    action.update(status: "pending")

    render turbo_stream: [
      turbo_stream.update(
        "action-#{ action.id }",
        partial: "actions/show",
        locals: { action: action }
      ),
      turbo_update_fire_all
    ]
  end

  def skip
    action.update(status: 'skipped')

    render turbo_stream: [
      turbo_stream.update(
        "action-#{ action.id }",
        partial: "actions/show",
        locals: { action: action }
      ),
      turbo_update_fire_all
    ]
  end

  def unexecute
    action.unfire!

    render turbo_stream: [
      turbo_stream.update(
        "action-#{ action.id }",
        partial: "actions/show",
        locals: { action: action }
      ),
      turbo_update_fire_all,
      turbo_update_commit_button
    ]
  end

  def unskip
    action.update(status: 'pending')

    render turbo_stream: [
      turbo_stream.update(
        "action-#{ action.id }",
        partial: "actions/show",
        locals: { action: action }
      ),
      turbo_update_fire_all
    ]
  end

  private

  helper_method :action
  def action
    @action ||= robo_job.actions.find_by(id: params[:id])
  end

  def robo_job
    @robo_job ||= RoboJob.find_by(id: params[:robo_job_id])
  end

  def turbo_update_fire_all
    turbo_stream.update(
      "fire-all-#{robo_job.id}",
      partial: "actions/fire_all",
      locals: { robo_job: robo_job }
    )
  end

  def turbo_update_commit_button
    turbo_stream.update(
      "commit-button",
      partial: "actions/commit_button",
      locals: { robo_job: robo_job }
    )
  end
end
