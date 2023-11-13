class RoboRequest < ApplicationRecord
  REQUEST_TYPES = [
    "contextual_files",
    "instructions",
  ]

  belongs_to :robo_job
  has_one :project, through: :robo_job

  validates :prompt, presence: true
  validates :request_type, presence: true, inclusion: { in: REQUEST_TYPES }

  def self.of_type(type)
    where(request_type: type).by_id
  end

  def initialize(*args)
    super(*args)
    self.prompt = PromptGenerator.new(self).generate_prompt
  end

  def fire!(sse_proc=nil)
    self.response = robot_api.ask_gpt4(prompt, sse_proc)

  rescue RobotError
    # do nothing if fails

  ensure
    self.raw_response = {}
    save!
  end

  private

  def robot_api
    @robot_api ||= RobotApi.new
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
