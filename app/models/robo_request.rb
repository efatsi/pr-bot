class RoboRequest < ApplicationRecord
  after_save :calculate_token_usage_and_cost, if: :saved_change_to_response?

  REQUEST_TYPES = [
    "contextual_files",
    "instructions",
    "commit_message",
  ]

  belongs_to :parent, polymorphic: true

  validates :prompt, presence: true
  validates :request_type, presence: true, inclusion: { in: REQUEST_TYPES }

  def self.of_type(type)
    where(request_type: type).by_id
  end

  def initialize(*args)
    super(*args)
    self.prompt = PromptGenerator.new(self).generate_prompt
  end

  def project
    if parent.is_a?(Project)
      parent
    else
      parent.project
    end
  end

  def fire!(sse_proc=nil)
    self.response = robot_api.ask_gpt4(prompt, sse_proc)

  rescue RobotError
    # do nothing if fails

  ensure
    self.raw_response = {}
    save!
  end

  def calculate_token_usage_and_cost
    encoder = Tiktoken.encoding_for_model('gpt-4')
    self.prompt_token_count = encoder.encode(prompt).length
    self.response_token_count = encoder.encode(response).length if response.present?
    self.cost = (prompt_token_count + response_token_count.to_i) / 70000.0
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
#  id                   :bigint           not null, primary key
#  cost                 :decimal(8, 2)
#  parent_type          :string           not null
#  prompt               :text             not null
#  prompt_token_count   :integer
#  raw_response         :json             not null
#  request_type         :string           not null
#  response             :text
#  response_token_count :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  parent_id            :bigint           not null
#
# Indexes
#
#  index_robo_requests_on_parent  (parent_type,parent_id)
#
