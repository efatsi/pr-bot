class RoboManager
  attr_reader :parent, :request_type, :robo_request

  def initialize(parent, request_type)
    @parent = parent
    @request_type = request_type
    @robo_request = parent.robo_requests.new(request_type: request_type)

    # set this on initialization so prompt can be viewed while processing
    @robo_request.prompt_messages = prompt_messages
  end

  def run_request(sse_proc=nil)
    response = robot_api.ask_gpt4(prompt_messages, sse_proc)
    robo_request.update(prompt_messages: prompt_messages, response: response)

    case robo_request.request_type
    when "contextual_files"
      parent.update(contextual_files: parent.dig_out_contextual_files(robo_request))
    when "instructions"
      parent.update(generated_instructions: JSON.parse(robo_request.response))
      parent.process_instructions_to_changes
    when "commit_suggestions"
      parent.update(message_options: JSON.parse(robo_request.response))
    end
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
end
