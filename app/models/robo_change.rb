class RoboChange < ApplicationRecord
  belongs_to :robo_job

  validates :raw_json, presence: true
end

# == Schema Information
#
# Table name: robo_changes
#
#  id               :bigint           not null, primary key
#  action           :string
#  file             :string
#  new_content      :text
#  original_content :text
#  raw_json         :json             not null
#  summary          :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  robo_job_id      :bigint           not null
#
# Indexes
#
#  index_robo_changes_on_robo_job_id  (robo_job_id)
#
# Foreign Keys
#
#  fk_rails_...  (robo_job_id => robo_jobs.id)
#
