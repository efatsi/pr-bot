class RoboJob < ApplicationRecord
  belongs_to :project

  has_many :robo_requests, -> { by_id }, as: :parent, dependent: :destroy
  has_many :contextual_files, dependent: :destroy

  has_many :followup_jobs, -> { by_id }, class_name: "RoboJob", foreign_key: :parent_job_id, dependent: :destroy
  belongs_to :parent_job, class_name: "RoboJob", optional: true

  has_many :robo_events, as: :subject, dependent: :destroy

  has_many :git_commits, dependent: :destroy

  validates :feature_request, presence: true

  array_field :seed_contextual_files

  scope :parent_jobs, -> { where(parent_job_id: nil) }

  def all_feature_requests
    if is_parent_job?
      [feature_request, *followup_jobs.map(&:feature_request)].compact
    else
      [feature_request]
    end
  end

  def enhanced_feature_request
    if enhance_request = robo_requests.active.of_type("enhance_feature_request").last
      enhance_request.response
    else
      feature_request
    end
  end

  def last_contextual_files
    last_job = followup_jobs.last || self
    (last_job.final_contextual_files + last_job.active_actions.map(&:file).compact).uniq
  end

  def final_contextual_files
    (seed_contextual_files + contextual_files.accepted.map(&:filepath)).uniq
  end

  def includes_past_convo?
    include_last_convo? || include_all_convos?
  end

  def total_cost
    robo_requests.sum(:cost)
  end

  def last_active_event
    event = start_event

    while event.child_robo_events.active.with_finished_requests.any?
      event = event.child_robo_events.active.first
    end

    event
  end

  def start_event
    robo_events.find_by(event_type: "start")
  end

  def stream_key
    if is_parent_job?
      "robo-job-#{id}-stream"
    else
      parent_job.stream_key
    end
  end

  def parent_job_or_self
    if is_parent_job?
      self
    else
      parent_job.parent_job_or_self
    end
  end

  def active_actions
    robo_requests.active.of_type(["build_instructions", "followup_instructions"]).flat_map(&:actions)
  end

  def generated_instructions
    robo_requests.active.of_type(["build_instructions", "followup_instructions"]).last&.response
  end

  def inspect
    "#<#{self.class}:0x#{object_id.to_s(16)} id: #{id}, feature_request: #{feature_request&.truncate(50)}, created_at: #{created_at}, updated_at: #{updated_at}, parent_job_id: #{parent_job_id}, project_id: #{project_id}>"
  end

  private

  def is_parent_job?
    parent_job_id.nil?
  end
end

# == Schema Information
#
# Table name: robo_jobs
#
#  id                    :bigint           not null, primary key
#  feature_request       :text             not null
#  include_all_convos    :boolean          default(FALSE)
#  include_last_convo    :boolean          default(FALSE)
#  seed_contextual_files :string           default([]), is an Array
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  parent_job_id         :bigint
#  project_id            :bigint
#
# Indexes
#
#  index_robo_jobs_on_parent_job_id  (parent_job_id)
#  index_robo_jobs_on_project_id     (project_id)
#
# Foreign Keys
#
#  fk_rails_...  (parent_job_id => robo_jobs.id)
#  fk_rails_...  (project_id => projects.id)
#
