class RoboEvent < ApplicationRecord
  EVENT_TYPES = [
    "start",
    "enhance_feature_request",
    "enhance_contextual_files",
    "build_instructions",
    "followup_instructions",
    "commit_suggestions",
  ]

  STATUSES = %w[active ignored]

  belongs_to :parent_robo_event, class_name: "RoboEvent", optional: true
  has_many :child_robo_events, class_name: "RoboEvent", foreign_key: :parent_robo_event_id

  has_many :robo_requests, -> { by_id }, dependent: :destroy

  belongs_to :subject, polymorphic: true

  validates :event_type, presence: true, inclusion: { in: EVENT_TYPES }
  validates :status, presence: true, inclusion: { in: STATUSES }

  # To temporarily mark an event as "fresh"
  attr_accessor :just_finished

  def self.of_type(type)
    where(event_type: type).by_id
  end

  def event_keyword
    case event_type
    when "start"
      "start"
    when "enhance_feature_request"
      "enhance\nfeature"
    when "enhance_contextual_files"
      "enhance\nfiles"
    when "build_instructions"
      "build\nactions"
    end
  end

  # todo, use this in RoboConductor and codify request types
  def has_multiple_requests?
    event_type == "enhance_feature_request"
  end
end

# == Schema Information
#
# Table name: robo_events
#
#  id                   :bigint           not null, primary key
#  event_data           :json
#  event_type           :string           not null
#  status               :string           default("active"), not null
#  subject_type         :string           not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  parent_robo_event_id :bigint
#  subject_id           :bigint           not null
#
# Indexes
#
#  index_robo_events_on_parent_robo_event_id  (parent_robo_event_id)
#  index_robo_events_on_subject               (subject_type,subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (parent_robo_event_id => robo_events.id)
#
