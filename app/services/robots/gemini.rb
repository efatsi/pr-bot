module Robots
  class Gemini < BaseRobot

    def chat(message)
      # Define this in OpenAI format, will be converted
      prompt_messages = [
        { role: 'user', content: message }
      ]

      conversation(prompt_messages)
    end

    def conversation(prompt_messages)
      check_token_limit(prompt_messages)

      # Convert from OpenAI format to Gemini format
      prompt_messages = to_gemini(prompt_messages)

      @response = ""

      result = client.stream_generate_content(prompt_messages) do |event, _parsed, _raw|
        new_content = event.dig("candidates", 0, "content", "parts", 0, "text")
        handle_streamed_content(new_content)
      end

      if @response.include?("```")
        # remove anything before the first ``` line (including language key)
        @response.gsub!(/^.*?```\w*\n/m, "")

        # remove anything after the last ``` line
        @response.gsub!(/```.*$/m, "")
      end

      puts
      @response
    end

    private

    def client
      @client ||= ::Gemini.new(
        credentials: {
          service: "generative-language-api",
          api_key: ENV["GOOGLE_AI_API_KEY"]
        },
        options: { model: "gemini-pro", server_sent_events: true }
      )
    end

    def to_gemini(prompt_messages)
      messages = prompt_messages.map do |message|
        {
          role: message["role"] == "user" ? "user" : "model",
          parts: [{ text: message["content"] }]
        }
      end

      { contents: messages }
    end
  end
end
