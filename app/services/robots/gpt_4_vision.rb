module Robots
  class Gpt4Vision < Gpt4
    GPT_4_VISION = "gpt-4o"

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

    private

    def model_key
      GPT_4_VISION
    end
  end
end
