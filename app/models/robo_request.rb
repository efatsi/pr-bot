class RoboRequest < ApplicationRecord
  REQUEST_TYPES = [
    "enhance_feature_request",
    "enhance_contextual_files",
    "build_instructions",
    "followup_instructions",
    "commit_suggestions",
  ]

  STATUSES = %w[active ignored error]

  after_save :calculate_token_usage_and_cost, if: :saved_change_to_response?

  belongs_to :parent, polymorphic: true
  belongs_to :robo_event, optional: true

  has_many :actions, -> { by_id }, dependent: :destroy

  delegate :project, to: :parent

  validates :request_type, presence: true
  validates :prompt, presence: true

  validates :request_type, inclusion: { in: REQUEST_TYPES }

  validates :status, inclusion: { in: STATUSES }

  STATUSES.each do |status|
    scope status, -> { where(status: status) }

    define_method("#{status}?") { self.status == status }
  end

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

  def all_siblings
    robo_event.robo_requests
  end

  def sibling_requests
    all_siblings.where.not(id: self.id)
  end

  def has_active_siblings?
    sibling_requests.active.any?
  end

  def younger_siblings
    all_siblings.where("id < ?", id)
  end

  def older_siblings
    all_siblings.where("id > ?", id)
  end

  def inspect
    "#<#{self.class}:0x#{object_id.to_s(16)} id: #{id}, request_type: '#{request_type}', created_at: #{created_at}, updated_at: #{updated_at}, parent_type: #{parent_type}, parent_id: #{parent_id}, robot: '#{robot}'>"
  end
end

# == Schema Information
#
# Table name: robo_requests
#
#  id                   :bigint           not null, primary key
#  cost                 :decimal(8, 2)
#  error                :text
#  parent_type          :string           not null
#  prompt_messages      :json
#  prompt_token_count   :integer
#  raw_response         :json             not null
#  request_type         :string           not null
#  response             :text
#  response_token_count :integer
#  robot                :string
#  status               :string           default("active")
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  parent_id            :bigint           not null
#  robo_event_id        :bigint
#
# Indexes
#
#  index_robo_requests_on_parent         (parent_type,parent_id)
#  index_robo_requests_on_robo_event_id  (robo_event_id)
#
# Foreign Keys
#
#  fk_rails_...  (robo_event_id => robo_events.id)
#
