class ContextualFile < ApplicationRecord
  belongs_to :robo_job

  STATUSES = [
    "pending",
    "robo_reviewed",
    "accepted",
    "tabled",
    "ignore"
  ]

  validates :status, presence: true, inclusion: { in: STATUSES }

  STATUSES.each do |status|
    scope status, -> { where(status: status) }

    define_method("#{status}?") do
      self.status == status
    end
  end
end

# == Schema Information
#
# Table name: contextual_files
#
#  id            :bigint           not null, primary key
#  filepath      :string
#  robo_analysis :json
#  status        :string           default("pending")
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  robo_job_id   :bigint           not null
#
# Indexes
#
#  index_contextual_files_on_robo_job_id  (robo_job_id)
#
# Foreign Keys
#
#  fk_rails_...  (robo_job_id => robo_jobs.id)
#
