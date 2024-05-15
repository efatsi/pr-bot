class RoboEvent < ApplicationRecord
  EVENT_TYPES = [
    "start",
    "enhance_feature_request",
    "expand_contextual_files",
    "examine_contextual_files",
    "build_instructions",
    "followup_instructions",
    "git_commit",
  ]

  STATUSES = %w[active ignored]

  belongs_to :parent_robo_event, class_name: "RoboEvent", optional: true
  has_many :child_robo_events, class_name: "RoboEvent", foreign_key: :parent_robo_event_id, dependent: :destroy

  has_many :robo_requests, -> { by_id }
  has_many :actions, -> { by_id }, through: :robo_requests

  has_many :contextual_files, dependent: :destroy

  before_destroy :disconnect_and_ignore_requests

  belongs_to :subject, polymorphic: true

  delegate :project, to: :subject

  scope :active, -> { where(status: "active") }
  scope :with_finished_requests, -> { joins(:robo_requests).where.not(robo_requests: { response: nil }) }

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
    when "expand_contextual_files"
      "expand\nfiles"
    when "examine_contextual_files"
      "examine\nfiles"
    when "build_instructions", "followup_instructions"
      "build\nactions"
    when "git_commit"
      "commit"
    end
  end

  def is_start_event?
    event_type == "start"
  end

  def is_instruction_event?
    event_type.in? [
      "build_instructions",
      "followup_instructions"
    ]
  end

  def robo_job
    case subject
    when RoboJob
      subject.parent_job_or_self
    when GitCommit
      subject.robo_job
    end
  end

  def event_request_type
    if event_type == "git_commit"
      "commit_suggestions"
    elsif event_type == "examine_contextual_files"
      "examine_contextual_file"
    else
      event_type
    end
  end

  private

  def disconnect_and_ignore_requests
    robo_requests.update_all(
      robo_event_id: nil,
      status: "ignored"
    )
  end
end

# == Schema Information
#
# Table name: robo_events
#
#  id                   :bigint           not null, primary key
#  event_data           :json
#  event_type           :string           not null
#  robots               :string           default([]), is an Array
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
