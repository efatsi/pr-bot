module Robots
  class Gpt < BaseRobot
    GPT_4_TURBO = "gpt-4-1106-preview"
    GPT_4 = "gpt-4"

    # ~70k = $1
    PROMPT_MAX_LENGTH = 30_000

    def chat(message)
      prompt_messages = [
        { role: "user", content: message }
      ]

      conversation(prompt_messages)
    end

    def conversation(prompt_messages)
      check_token_limit(prompt_messages)

      @response = ""

      json_mode = prompt_messages.map{|a| a["content"]}.any? {|a| a.include? PromptHub::RETURN_AS_JSON}

      client.chat(
        parameters: {
          model: GPT_4_TURBO,
          messages: prompt_messages,
          response_format: { type: json_mode ? "json_object" : "text" },
          temperature: 0.2,
          stream: stream_proc,
        }
      )

      puts
      @response
    end

    private

    def check_token_limit(prompt_messages)
      # first check prompt length is less than PROMPT_MAX_LENGTH
      encoder = Tiktoken.encoding_for_model('gpt-4')
      prompt_content = prompt_messages.map{|a| a["content"]}.join(" ")
      token_count = encoder.encode(prompt_content).length

      if token_count > PROMPT_MAX_LENGTH
        raise "Prompt is #{token_count} tokens, max is #{PROMPT_MAX_LENGTH}."
      end
    end

    def stream_proc
      proc do |chunk, _bytesize|
        new_content = chunk.dig("choices", 0, "delta", "content")
        handle_streamed_content(new_content)
      end
    end

    def client
      @client ||= OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
    end
  end
end
