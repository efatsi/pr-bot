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
    end

    def handle_response
      response_arguments = JSON.parse(robo_request.response)
      new_arguments = action.arguments.merge(response_arguments)

      action.update(arguments: new_arguments)
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
    end

    def primary_target
      "action-#{action.id}"
    end
  end
end
