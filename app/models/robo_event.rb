class RoboEvent < ApplicationRecord
  EVENT_TYPES = [
    "new_job",
    "enhance_feature",
    "enhance_files",
    "generate_actions",
  ]

  STATUSES = %w[active ignored]

  belongs_to :parent_robo_event, class_name: "RoboEvent", optional: true
  belongs_to :subject, polymorphic: true

  validates :event_type, presence: true, inclusion: { in: EVENT_TYPES }
  validates :status, presence: true, inclusion: { in: STATUSES }
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
