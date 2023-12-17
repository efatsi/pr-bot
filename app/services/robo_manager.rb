class RoboManager
  # Toggle this off to disable fetches to the AI API
  ROBOT_ENABLED = true

  attr_reader :parent, :request_type, :robo_request

  def initialize(parent, request_type)
    # RoboJob or GitCommit
    @parent = parent

    @request_type = request_type
    @robo_request = parent.robo_requests.new(request_type: request_type)

    # set this on initialization so prompt can be viewed while processing
    @robo_request.prompt_messages = prompt_messages
  end

  def run_request
    # First, broadcast the processing state

    ActionCable.server.broadcast(parent.stream_key, {
      turbo_stream: turbo_stream_action("update",
        target: "get-files",
        partial: "robo_jobs/files/processing",
        locals: { robo_request: robo_request }
      )
    })

    # bail early if robot disabled
    if !ROBOT_ENABLED
      send_test_response
      return
    end

    # run request
    response = robot_api.ask_gpt4(prompt_messages, stream_proc)
    robo_request.update(prompt_messages: prompt_messages, response: response)

    # handle response based on request type
    case robo_request.request_type
    when "contextual_files"
      parent.update(contextual_files: parent.dig_out_contextual_files(robo_request))
    when "instructions"
      parent.update(generated_instructions: JSON.parse(robo_request.response))
      parent.process_instructions_to_changes
    when "commit_suggestions"
      parent.update(message_options: JSON.parse(robo_request.response))
    end

    # broadcast the finished state
    ActionCable.server.broadcast(parent.stream_key, {
      turbo_stream: [
        turbo_stream_action("update",
          target: "get-files",
          partial: "robo_jobs/files/finished",
          locals: {
            robo_job: parent.reload,
            robo_request: robo_request,
            ding: true,
            open_on_load: true
          }
        ),
        turbo_stream_action("update",
          target: "get-instructions",
          partial: "robo_jobs/instructions/index",
          locals: { robo_job: parent }
        )
      ]

    })
  end

  private

  def prompt_messages
    @prompt_messages ||= prompt_generator.prompt_messages
  end

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

  def turbo_stream_action(action, target:, partial:, locals: {})
    # Tried to use turbo_stream.update but it struggles w/ `host` context during rendering being outside of a controller
    # ApplicationController.render works just fine though, so using that here and pushing in as plaintext
    turbo_stream.send(
      action,
      target,
      plain: ApplicationController.render(partial: partial, locals: locals)
    )
  end

  def turbo_stream
    @turbo_stream ||= ApplicationController.new.view_context.turbo_stream
  end
end
