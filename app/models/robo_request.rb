class RoboRequest < ApplicationRecord
  after_save :calculate_token_usage_and_cost, if: :saved_change_to_response?

  REQUEST_TYPES = [
    "contextual_files",
    "instructions",
    "commit_suggestions",
  ]

  belongs_to :parent, polymorphic: true

  delegate :project, to: :parent

  validates :request_type, presence: true, inclusion: { in: REQUEST_TYPES }
  validates :prompt, presence: true

  def self.of_type(type)
    where(request_type: type).by_id
  end

  def calculate_token_usage_and_cost
    encoder = Tiktoken.encoding_for_model('gpt-4')
    self.prompt_token_count = encoder.encode(prompt_messages.map{|a| a["content"]}.join(" ")).length
    self.response_token_count = encoder.encode(response).length if response.present?
    self.cost = (prompt_token_count + response_token_count.to_i) / 70000.0
    save!
  end

  def prompt
    if prompt_messages.present?
      prompt_messages.last["content"]
    end
  end
end

# == Schema Information
#
# Table name: robo_requests
#
#  id                   :bigint           not null, primary key
#  cost                 :decimal(8, 2)
#  parent_type          :string           not null
#  prompt_messages      :json
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
