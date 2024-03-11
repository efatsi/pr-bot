class ActionsController < SseApplicationController
  before_action :set_sse_headers, only: :execute_all

  def execute_all
    pending_count = robo_request.actions.pending.count
    robo_request.actions.pending.each_with_index do |action, i|
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
        turbo_update_next_steps
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
      turbo_update_next_steps
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
      turbo_update_next_steps
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
    @action ||= Action.find_by(id: params[:id])
  end

  def robo_request
    @robo_request ||= if params[:robo_request_id]
      RoboRequest.find_by(id: params[:robo_request_id])
    else
      action.robo_request
    end
  end

  def robo_event
    @robo_event ||= robo_request.robo_event
  end

  def turbo_update_fire_all
    turbo_stream.update(
      "fire-all-#{robo_request.id}",
      partial: "actions/buttons/fire_all",
      locals: { robo_request: robo_request }
    )
  end

  def turbo_update_next_steps
    turbo_stream.update(
      "next-steps-#{robo_event.id}",
      partial: "robo_events/build_instructions/next_steps",
      locals: { robo_event: robo_event }
    )
  end
end
