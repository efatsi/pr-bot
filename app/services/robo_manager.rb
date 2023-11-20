class RoboManager
  attr_reader :parent
  def initialize(parent)
    @parent = parent
  end

  def prepare_request(type)
    parent.robo_requests.new(request_type: type)
  end

  def run_request(robo_request, sse_proc=nil)
    robo_request.fire!(sse_proc)

    if robo_request.response
      case robo_request.request_type
      when "contextual_files"
        parent.update(contextual_files: dig_out_contextual_files(robo_request))
      when "instructions"
        parent.update(generated_instructions: robo_request.response)
        parent.process_instructions_to_changes
      when "commit_message"
        parent.update(message_options: robo_request.response)
      end
    else
      raise "Error: #{robo_request.raw_response}"
    end
  end
end
