class RoboConductor
  include ServiceStreamHelpers

  # Toggle this off to disable fetches to the AI API
  ROBOT_ENABLED = true

  attr_reader :parent, :request_type, :robo_request

  def initialize(parent, request_type)
    # RoboJob or GitCommit
    @parent = parent

    @request_type = request_type
    @robo_request = parent.robo_requests.new(request_type: request_type)
  end

  def run_request
    # generate prompt messages
    robo_request.prompt_messages = prompt_generator.prompt_messages

    # broadcast processing state
    handler.broadcast_processing_state

    if ROBOT_ENABLED
      # run request
      response = robot_api.ask_gpt4(robo_request.prompt_messages, stream_proc)
      robo_request.update(response: response)

      # handle response
      handler.handle_response

      # broadcast finished state
      handler.broadcast_finished_state
    else
      send_dummy_response
    end
  rescue => error
    handler.broadcast_error_state(error)
  end

  private

  def prompt_generator
    @prompt_generator ||= PromptGenerator.new(robo_request)
  end

  def robot_api
    @robot_api ||= RobotApi.new
  end

  def send_dummy_response
    sleep(0.5)
    stream_proc.call("This is a demo response.")
    sleep(0.5)
    stream_proc.call("\nFlip ROBOT_ENABLED to true to see the real thing!")
  end

  def stream_proc
    proc do |new_chars|
      ActionCable.server.broadcast(parent.stream_key, {
        turbo_stream: turbo_stream.append(
          "ai-response",
          plain: new_chars
        )
      })
    end
  end

  def handler
    @handler ||= case request_type
    when "contextual_files"
      Handlers::ContextualFilesHandler.new(robo_request)
    when "build_plan"
      Handlers::BuildPlanHandler.new(robo_request)
    when "instructions"
      Handlers::InstructionsHandler.new(robo_request)
    when "followup_instructions"
      Handlers::FollowupInstructionsHandler.new(robo_request)
    when "commit_suggestions"
      Handlers::CommitSuggestionsHandler.new(robo_request)
    end
  end
end
