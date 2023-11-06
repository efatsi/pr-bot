class RobotError < StandardError; end

PROMPT_MAX_LENGTH = 3200

class RobotApi
  attr_reader :response

  def ask_gpt4(prompt)
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

    @response = client.chat(
      parameters: {
        model: "gpt-4",
        messages: [{ role: "user", content: prompt }],
        temperature: 0.1,
      }
    )

    if response["error"]
      raise RobotError("OpenAI API Error: #{response.dig("error", "message")}")
    end

    puts response
    puts

    response.dig("choices", 0, "message", "content")
  end

  private

  def client
    @client ||= OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
  end
end
