class RobotError < StandardError; end

# GPT_4_TURBO accepts up to 128k, keeping it at 10k for now (~70k = $1)
PROMPT_MAX_LENGTH = 10_000

GPT_4 = "gpt-4"
GPT_4_TURBO = "gpt-4-1106-preview"

class RobotApi
  def ask_gpt4(prompt, sse_proc=nil)
    json_mode = prompt.include?(RoboRequest::RETURN_AS_JSON)

    # first check prompt length is less than PROMPT_MAX_LENGTH
    token_count = OpenAI.rough_token_count(prompt)
    if token_count > PROMPT_MAX_LENGTH
      puts "Prompt length is #{token_count} tokens, which is greater than the maximum of #{PROMPT_MAX_LENGTH} tokens. Please shorten your prompt."
      puts "Prompt start: #{prompt[0..100]}..."

      raise RobotError.new("Prompt length is #{token_count} tokens, which is greater than the maximum of #{PROMPT_MAX_LENGTH} tokens. Please shorten your prompt.")
    end

    puts "=========================="
    puts "Requesting: #{prompt[0..300]}..."
    puts

    @response = ""

    client.chat(
      parameters: {
        model: GPT_4_TURBO,
        messages: [{ role: "user", content: prompt }],
        response_format: { type: json_mode ? "json_object" : "text" },
        temperature: 0.2,
        stream: stream_proc(sse_proc),
      }
    )

    @response
  end

  private

  def stream_proc(sse_proc=nil)
    proc do |chunk, _bytesize|
      if new_content = chunk.dig("choices", 0, "delta", "content")
        @response += new_content

        if sse_proc
          sse_proc.call(new_content)
        end
      end
    end
  end

  def client
    @client ||= OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
  end
end
