class RobotError < StandardError; end

class RobotApi
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
        stream: stream_proc,
      }
    )

    puts
    @response
  end

  def ask_gpt4(prompt_messages, stream_proc_input=nil)
    check_token_limit(prompt_messages)
    print_intro(prompt_messages)

    json_mode = prompt_messages.map{|a| a["content"]}.any? {|a| a.include? "JSON"}

    client.chat(
      parameters: {
        model: GPT_4_TURBO,
        messages: prompt_messages,
        response_format: { type: json_mode ? "json_object" : "text" },
        temperature: 0.2,
        stream: stream_proc(stream_proc_input),
      }
    )

    puts
    @response
  end

  def ask_google(prompt_messages)
    generate_url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=#{ENV["GOOGLE_AI_API_KEY"]}"

    google_prompts = prompt_messages.dup.map do |message|
      message.with_indifferent_access.tap do |m|
        m[:role] = m[:role] == "system" ? "model" : m[:role]
        m[:parts] = [{ text: m.delete(:content) }]
      end
    end

    # no streamed responses to be had in google land
    google_response = HTTParty.post(
      generate_url,
      headers: { "Content-Type" => "application/json" },
      body: { contents: google_prompts }.to_json
    )

    @response = google_response.dig("candidates", 0, "content", "parts", 0, "text").gsub("```", "")
  end

  def chat_google(message)
    # google_prompts = [
    #   { role: "model", parts: { text: "You are a helpful assistant." } },
    #   { role: "user", parts: { text: message } },
    # ],

    client = Gemini.new(
      credentials: {
        service: 'generative-language-api',
        api_key: ENV['GOOGLE_AI_API_KEY']
      },
      options: { model: 'gemini-pro', server_sent_events: true }
    )

    result = client.generate_content(
      { contents: { role: 'user', parts: { text: message } } }
    )

    @response = ""
    result = client.stream_generate_content(
      { contents: { role: 'user', parts: { text: message } } }
    ) do |event, parsed, raw|
      new_content = event.dig("candidates", 0, "content", "parts", 0, "text")
      @response += new_content

      print(new_content)
    end

    puts
    @response
  end

  private

  def stream_proc(stream_proc_input=nil)
    @response = ""

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
    proc { |msg| print msg }
  end

  def client
    @client ||= OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
  end
end
