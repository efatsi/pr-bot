class RoboManager
  attr_reader :parent, :request_type, :robo_request

  def initialize(parent, request_type)
    @parent = parent
    @request_type = request_type
    @robo_request = parent.robo_requests.new(request_type: request_type)
  end

  def run_request(sse_proc=print_proc)
    robo_request.fire!(sse_proc)

    if robo_request.response
      case robo_request.request_type
      when "contextual_files"
        parent.update(contextual_files: dig_out_contextual_files(robo_request))
      when "instructions"
        parent.update(generated_instructions: robo_request.response)
        parent.process_instructions_to_changes
      when "commit_suggestions"
        parent.update(message_options: JSON.parse(robo_request.response))
      end
    else
      raise "Error: #{robo_request.raw_response}"
    end
  end

  # have this here as a default for testing
  def print_proc
    proc { |msg| print msg }
  end
end
