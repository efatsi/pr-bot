class RoboManager
  include ServiceStreamHelpers

  # Toggle this off to disable fetches to the AI API
  ROBOT_ENABLED = true

  attr_reader :parent, :request_type, :robo_request

  def initialize(parent, request_type)
    # RoboJob or GitCommit
    @parent = parent

    @request_type = request_type
    @robo_request = parent.robo_requests.new(request_type: request_type)

    # set this on initialization so prompt can be viewed while processing
    @robo_request.prompt_messages = prompt_generator.prompt_messages
  end

  def run_request
    # broadcast processing state
    handler.broadcast_processing_state

    # bail early if robot disabled
    if !ROBOT_ENABLED
      send_test_response
      return
    end

    # run request
    response = robot_api.ask_gpt4(robo_request.prompt_messages, stream_proc)
    robo_request.update(response: response)

    handler.handle_response

    # handle response based on request type
    handler.broadcast_finished_state
    case robo_request.request_type
    when "instructions"
      parent.update(generated_instructions: JSON.parse(robo_request.response))
      parent.process_instructions_to_changes
    when "commit_suggestions"
      parent.update(message_options: JSON.parse(robo_request.response))
    end
  end

  private

  def prompt_generator
    @prompt_generator ||= PromptGenerator.new(robo_request)
  end

  def robot_api
    @robot_api ||= RobotApi.new
  end

  def send_test_response
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
    when "instructions"
      Handlers::InstructionsHandler.new(robo_request)
    when "commit_suggestions"
      Handlers::CommitSuggestionsHandler.new(robo_request)
    end
  end
end
