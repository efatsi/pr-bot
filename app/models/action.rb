class Action < ApplicationRecord
  belongs_to :robo_job
  belongs_to :action_template

  STATUSES = [
    "pre_flight",
    "pending",
    "executed",
    "failed",
    "skipped"
  ]

  validates :status, presence: true, inclusion: { in: STATUSES }

  STATUSES.each do |status|
    scope status, -> { where(status: status) }

    define_method("#{status}?") do
      self.status == status
    end
  end

  def execute
  end

  def revert
  end

  def timestamped_file
    file = arguments[:file]

    if "/[timestamp]_".in?(file.downcase) || "/timestamp_".in?(file.downcase)
      file.gsub(/\[?timestamp\]?/i, Time.now.strftime("%Y%m%d%H%M%S"))
    else
      file
    end
  end

  def arguments
    super.with_indifferent_access
  end
end

# == Schema Information
#
# Table name: actions
#
#  id                 :bigint           not null, primary key
#  action_name        :string
#  arguments          :json
#  error              :text
#  history            :json
#  relevant_files     :json
#  status             :string           default("pending"), not null
#  summary            :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  action_template_id :bigint           not null
#  robo_job_id        :bigint           not null
#
# Indexes
#
#  index_actions_on_action_template_id  (action_template_id)
#  index_actions_on_robo_job_id         (robo_job_id)
#
# Foreign Keys
#
#  fk_rails_...  (action_template_id => action_templates.id)
#  fk_rails_...  (robo_job_id => robo_jobs.id)
#
