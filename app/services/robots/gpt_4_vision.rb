module Robots
  class Gpt4Vision < BaseRobot
    GPT_4_VISION = "gpt-4-turbo"

    def chat(message, image_upload)
      # Convert image to base64
      base64_image = Base64.strict_encode64(File.read(image_upload.image_path))

      prompt_messages = [{
        role: "user",
        content: [
          { type: "text", text: message },
          {
            type: "image_url",
            image_url: {
              url: "data:#{image_upload.image_content_type};base64,#{base64_image}",
              # detail: "low"
            }
          }
        ]
      }].map(&:with_indifferent_access)

      conversation(prompt_messages)
    end

    def conversation(prompt_messages)
      check_token_limit(prompt_messages)

      @response = ""

      json_mode = prompt_messages.map{|a| a["content"]}.any? {|a| a.include? PromptHub::RETURN_AS_JSON}

      client.chat(
        parameters: {
          model: model_key,
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

    def stream_proc
      proc do |chunk, _bytesize|
        new_content = chunk.dig("choices", 0, "delta", "content")
        handle_streamed_content(new_content)
      end
    end

    def client
      @client ||= OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
    end

    def model_key
      GPT_4_VISION
    end
  end
end
