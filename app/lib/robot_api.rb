class RobotError < StandardError; end

class RobotApi
  GPT_4 = "gpt-4"
  GPT_4_TURBO = "gpt-4-1106-preview"

  # ~70k = $1
  PROMPT_MAX_LENGTH = 30_000

  def ask_gpt4(prompt, sse_proc=nil, json_mode=true)
    # first check prompt length is less than PROMPT_MAX_LENGTH
    token_count = OpenAI.rough_token_count(prompt)
    if token_count > PROMPT_MAX_LENGTH
      raise RobotError.new("Prompt is #{token_count} tokens, max is #{PROMPT_MAX_LENGTH}.")
    end

    puts "=========================="
    puts "Requesting: #{prompt[0..300]}..."
    puts

    @response = ""

    begin
      client.chat(
        parameters: {
          model: GPT_4_TURBO,
          messages: [
            { role: "system", content: PromptGenerator::SYSTEM_SETUP },
            { role: "user", content: prompt }
          ],
          response_format: { type: json_mode ? "json_object" : "text" },
          temperature: 0.2,
          stream: stream_proc(sse_proc),
        }
      )
    rescue Exception => ex
      binding.pry if Rails.env.local?
    end

    @response
  end

  private

  def stream_proc(sse_proc=print_proc)
    proc do |chunk, _bytesize|
      if new_content = chunk.dig("choices", 0, "delta", "content")
        @response += new_content

        if sse_proc
          sse_proc.call(new_content)
        end
      end
    end
  end

  # have this here as a default for testing
  def print_proc
    proc { |msg| print msg }
  end

  def client
    @client ||= OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
  end
end
