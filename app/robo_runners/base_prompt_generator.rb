# flip this to true to disable full prompt generation, for testing rest of infrastructure
DUMMY_MODE = false

class BasePromptGenerator
  attr_reader :robo_request

  def initialize(robo_request)
    @robo_request = robo_request
  end

  def generate_prompt_messages
    return request_bird_facts if DUMMY_MODE

    prompt_messages
  end

  private

  def project
    @project ||= robo_request.project
  end

  def parent
    @parent ||= robo_request.parent
  end

  def project_tools
    [
      "You are working on a project with these tools:",
      project.project_context,
      "",
      "Prefer solutions that use the project tools over generic solutions."
    ].join("\n")
  end

  def robo_job_context_files
    contextual_file_data = robo_job.contextual_files.map do |file|
      {
        name: file,
        content: File.read(project.full_path(file))
      }
    end

    [
      "These are relevant project files to work with:",
      "<contextual_file_data>",
      contextual_file_data,
      "</contextual_file_data>"
    ].join("\n")
  end

  def request_bird_facts
    [
      { role: "system", content: "You are a bird scientist." },
      { role: "user", content: "Tell me a cool fact about migratory birds that I didn't know. In about 100 words." }
    ]
  end

  # must be implemented by subclass
  def prompt_messages
    raise NotImplementedError
  end
end
