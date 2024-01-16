module ActionRunners
  class BaseActionRunner < BaseRoboRunner

    alias :action :parent

    def prompt_messages
      runner_module = ActionRunners.const_get(action.type.demodulize)
      prompt = runner_module::Prompt.new(robo_request)

      prompt.generate_prompt_messages
    end

    private

    def robo_job
      @robo_job ||= action.robo_job
    end

    def broadcast_processing_state
      broadcast(
        partial: 'actions/processing',
        locals: { action: action, robo_request: robo_request }
      )

      broadcast(
        target: "fill-in-plan-#{robo_job.id}",
        action: :remove
      )
    end

    def handle_response
      response_arguments = JSON.parse(robo_request.response)
      new_arguments = action.arguments.merge(response_arguments)

      action.update(arguments: new_arguments, status: :pending)
    end

    def broadcast_finished_state
      broadcast(
        partial: 'actions/show',
        locals: {
          action: action.reload,
          robo_request: robo_request,
          ding: true
        }
      )

      broadcast_button_updates
    end

    def broadcast_error_state(error)
      broadcast(
        partial: "actions/processing_error",
        locals: {
          action: action,
          robo_request: robo_request,
          error: error,
        }
      )

      broadcast_button_updates
    end

    def primary_target
      "action-#{action.id}"
    end

    def stream_proc_target
      "ai-response-#{action.id}"
    end

    def broadcast_button_updates
      broadcast(
        partial: "actions/buttons/fire_all",
        target: "fire-all-#{robo_job.id}",
        locals: { robo_job: robo_job }
      )

      broadcast(
        partial: "actions/buttons/fill_in_plan",
        target: "fill-in-plan-#{robo_job.id}",
        locals: { robo_job: robo_job }
      )
    end
  end
end
