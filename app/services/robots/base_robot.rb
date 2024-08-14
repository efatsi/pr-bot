module Robots
  class BaseRobot
    # ~175k = $1
    PROMPT_MAX_LENGTH = 60_000

    def initialize(external_stream_proc = print_proc)
      @external_stream_proc = external_stream_proc
    end

    def handle_streamed_content(new_content)
      if new_content
        @response += new_content
        @external_stream_proc.call(new_content)
      end
    end

    # have this here as a default for testing
    def print_proc
      proc { |msg| print msg }
    end

    def check_token_limit(prompt_messages)
      # first check prompt length is less than PROMPT_MAX_LENGTH
      encoder = Tiktoken.encoding_for_model('gpt-4')
      prompt_content = prompt_messages.map{|a| a["content"]}.map do |content|
        # handle raw strings as well as array of hashes
        if content.is_a?(String)
          content
        elsif content.is_a?(Array)
          content.select { |sc| sc["type"] == "text" }.map { |sc| sc["text"] }.join(" ")
        end
      end.compact.join(" ")
      token_count = encoder.encode(prompt_content).length

      if token_count > PROMPT_MAX_LENGTH
        raise "Prompt is #{token_count} tokens, max is #{PROMPT_MAX_LENGTH}."
      end
    end
  end
end
