class ContextualFile < ApplicationRecord
  belongs_to :robo_job
end

# == Schema Information
#
# Table name: contextual_files
#
#  id            :bigint           not null, primary key
#  filepath      :string
#  robo_analysis :json
#  status        :string
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
