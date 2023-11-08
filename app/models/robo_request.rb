class RoboRequest < ApplicationRecord
  RETURN_AS_JSON = "Return the details of the implementation change as a JSON object with the following structure:"

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
        "How would you implement the following feature request?",
        "Feature request:",
        "[FEATURE_REQUEST]",
        "",
        "Here are the contextual project files:",
        "[FILES_CONTENT]",
        "",
        RETURN_AS_JSON,
        "- implementation_overview: Describe the steps involved to implement the feature",
        "- additional_notes: Any other details to know, or steps to take after the implementation is complete",
        "- changes: An array of all the file changes required, following this structure:",
        "  - summary: A brief description of the change",
        "  - action: one of `#{RoboChange::VALID_ACTIONS.join('`, `')}`",
        "  - file: path to the file",
        "  - original_content: the exact content of the file, only that which will be changed by the new_content",
        "  - new_content: the new content required for the feature",
        "",
        "Example",
        '{
  "implementation_overview": "We need to add a new member route to the robo_jobs resources in the routes.rb file and create a new controller action along with a corresponding template file.",
  "changes": [
    {
      "summary": "Add a new `:robo_requests` member route to the `robo_jobs` resources",
      "action": "update_file",
      "file": "/pr-bot/config/routes.rb",
      "original_content": "resources :robo_jobs, only: [:new, :create, :show, :edit, :update] do",
      "new_content": "resources :robo_jobs, only: [:new, :create, :show, :edit, :update] do\n    get :robo_requests, on: :member"
    },
    {
      "summary": "Add a new `robo_requests` action to the `RoboJobsController`.",
      "action": "update_file",
      "file": "/pr-bot/app/controllers/robo_jobs_controller.rb",
      "orginal_content": "end\n\n  private",
      "new_content": "end\n\n  def robo_requests\n    @robo_job = RoboJob.find(params[:id])\n  end\n\n  private"
    },
    {
      "summary": "Add a new template file for the `robo_requests` action.",
      "action": "add_file",
      "file": "/pr-bot/app/views/robo_jobs/robo_requests.html.erb",
      "original_content": "",
      "new_content": "<h1>Robo Requests for <%= @robo_job.name %></h1>\n<% @robo_job.robo_requests.each do |request| %>\n  <div class=\"robo-request\">\n    <%# Display details of the request here %>\n  </div>\n<% end %>"
    }
  ],
  "additional_notes": "Check that the template is being rendered correctly at the path `/robo_jobs/:id/robo_requests`."
}',
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
