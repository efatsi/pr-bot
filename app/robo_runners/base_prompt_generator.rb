# flip this to true to disable full prompt generation, for testing rest of infrastructure
DUMMY_MODE = false

class BasePromptGenerator
  attr_reader :project, :subject

  def initialize(project, subject)
    @project = project
    @subject = subject
  end

  def generate_prompt_messages
    return request_bird_facts if DUMMY_MODE

    prompt_messages
  end

  private

  def robo_job_context_files(solutioning: false)
    contextual_file_data = robo_job.contextual_files.map do |file|
      {
        name: file,
        content: File.read(project.full_path(file))
      }
    end

    [
      project_tools(solutioning: solutioning),
      "",
      "Here are relevant files to the feature request:",
      "<contextual_source_files>",
      contextual_file_data,
      "</contextual_source_files>"
    ].join("\n")
  end

  def project_tools(solutioning: true)
    to_return = [
      "You are working on a project with these tools:",
      project.project_context,
    ]

    if solutioning
      to_return += [
        "",
        "Prefer solutions that use the project tools over generic solutions."
      ]
    end

    to_return.join("\n")
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
