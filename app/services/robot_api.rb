class RobotError < StandardError; end

class RobotApi
  class << self
    GPT_4 = "gpt-4"
    GPT_4_TURBO = "gpt-4-1106-preview"

    # ~70k = $1
    PROMPT_MAX_LENGTH = 30_000

    def chat(message)
      client.chat(
        parameters: {
          model: GPT_4_TURBO,
          messages: [
            { role: "system", content: "You are a helpful assistant." },
            { role: "user", content: message }
          ],
          response_format: { type: "text" },
          temperature: 0.2,
          stream: print_proc,
        }
      )
    end

    def ask_gpt4(prompt_messages, stream_proc_input=nil)
      check_token_limit(prompt_messages)
      print_intro(prompt_messages)

      json_mode = prompt_messages.map{|a| a["content"]}.any? {|a| a.include? "JSON"}

      @response = ""

      client.chat(
        parameters: {
          model: GPT_4_TURBO,
          messages: prompt_messages,
          response_format: { type: json_mode ? "json_object" : "text" },
          temperature: 0.2,
          stream: stream_proc(stream_proc_input),
        }
      )

      @response
    end

    private

    def stream_proc(stream_proc_input=nil)
      stream_proc_input ||= print_proc

      proc do |chunk, _bytesize|
        if new_content = chunk.dig("choices", 0, "delta", "content")
          @response += new_content

          stream_proc_input.call(new_content)
        end
      end
    end

    def check_token_limit(prompt_messages)
      # first check prompt length is less than PROMPT_MAX_LENGTH
      encoder = Tiktoken.encoding_for_model('gpt-4')
      prompt_content = prompt_messages.map{|a| a["content"]}.join(" ")
      token_count = encoder.encode(prompt_content).length

      if token_count > PROMPT_MAX_LENGTH
        raise RobotError.new("Prompt is #{token_count} tokens, max is #{PROMPT_MAX_LENGTH}.")
      end
    end

    def print_intro(prompt_messages)
      puts "================== Requesting: =================="
      puts "#{prompt_messages.last["content"][0..300]}..."
      puts
    end

    # have this here as a default for testing
    def print_proc
      # proc { |msg| print msg.dig("choices", 0, "delta", "content") }
      proc { |msg| print msg }
    end

    def client
      @client ||= OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
    end
  end
end
