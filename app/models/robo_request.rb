class RoboRequest < ApplicationRecord
  REQUEST_TYPES = [
    "contextual_files",
    "instructions",
  ]

  belongs_to :robo_job

  validates :prompt, presence: true
  validates :raw_response, presence: true
  validates :request_type, presence: true, inclusion: { in: REQUEST_TYPES }

  def self.of_type(type)
    where(request_type: type).by_id.last
  end

  def initialize(*args)
    super(*args)
    self.prompt = generate_prompt
  end

  def fire!
    self.response = robot_api.ask_gpt4(prompt)

  rescue RobotError
    # do nothing if fails

  ensure
    self.raw_response = robot_api.response
    save!
  end

  private

  def robot_api
    @robot_api ||= RobotApi.new
  end

  def prompt_structure
    @prompt_structure ||= case request_type
    when "contextual_files"
      [
        "What files from the Directory Tree should I review to implement the following feature request in this project?",
        "Directory Tree:",
        "[DIRECTORY_TREE]",
        "",
        "Feature request:",
        "[FEATURE_REQUEST]",
        "",
        "[PROJECT_CONTEXT]",
        "Be very concise in your response, only looking for files that are definitely relevant.",
      ]
    when "instructions"
      [
        "How would you implement the following feature request using Ruby methods add_file(filepath, text) and change_file(filepath, og_text, new_text)?",
        "Feature request:",
        "[FEATURE_REQUEST]",
        "",
        "Only make changes to these contextual files, or add new ones if necessary:",
        "[FILES_CONTENT]",
        "",
        "For each change, provide a very short summary and then a ruby code block w/ a single add_file or change_file call (```ruby)",
        "For the ruby code that you're adding or swapping in, follow the style of the contextual files",
        "[PROJECT_CONTEXT]"
      ]
    end
  end

  def generate_prompt
    prompt_structure.join("\n").tap do |p|
      # check "[DIRECTORY_TREE]",
      if "[DIRECTORY_TREE]".in?(p)
        p.gsub!("[DIRECTORY_TREE]", robo_job.fetch_directory_tree.join("\n"))
      end

      # check "[FILES_CONTENT]",
      if "[FILES_CONTENT]".in?(p)
        p.gsub!("[FILES_CONTENT]", robo_job.contextual_file_data.to_json)
      end

      # check "[FEATURE_REQUEST]",
      if "[FEATURE_REQUEST]".in?(p)
        p.gsub!("[FEATURE_REQUEST]", robo_job.feature_request)
      end

      # check "[PROJECT_CONTEXT]"
      if "[PROJECT_CONTEXT]".in?(p) && robo_job.project_context.present?
        p.gsub!("[PROJECT_CONTEXT]", "Things to know about this project:\n" + robo_job.project_context)
      end
    end
  end
end

# == Schema Information
#
# Table name: robo_requests
#
#  id           :bigint           not null, primary key
#  prompt       :text             not null
#  raw_response :json             not null
#  request_type :string           not null
#  response     :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  robo_job_id  :bigint           not null
#
# Indexes
#
#  index_robo_requests_on_robo_job_id  (robo_job_id)
#
# Foreign Keys
#
#  fk_rails_...  (robo_job_id => robo_jobs.id)
#
