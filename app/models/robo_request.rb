class RoboRequest < ApplicationRecord
  belongs_to :robo_job
end

# == Schema Information
#
# Table name: robo_requests
#
#  id           :bigint           not null, primary key
#  prompt       :text             not null
#  raw_response :json             not null
#  request_type :string           not null
#  response     :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  robo_job_id  :bigint           not null
#
# Indexes
#
#  index_robo_requests_on_robo_job_id  (robo_job_id)
#
# Foreign Keys
#
#  fk_rails_...  (robo_job_id => robo_jobs.id)
#
