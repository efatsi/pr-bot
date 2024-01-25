module Robots
  class Gemini < BaseRobot

    def chat(message)
      prompt_messages = { contents: [
        { role: 'user', parts: { text: message } }
      ] }

      conversation(prompt_messages)
    end

    def conversation(prompt_messages)
      # check_token_limit(prompt_messages)

      @response = ""

      result = client.stream_generate_content(prompt_messages) do |event, _parsed, _raw|
        new_content = event.dig("candidates", 0, "content", "parts", 0, "text")
        handle_streamed_content(new_content)
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
  end
end
