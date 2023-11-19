class GitCommit < ApplicationRecord
  belongs_to :robo_job, optional: true
end

# == Schema Information
#
# Table name: git_commits
#
#  id          :bigint           not null, primary key
#  commit_hash :string
#  message     :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  project_id  :bigint           not null
#  robo_job_id :bigint
#
# Indexes
#
#  index_git_commits_on_commit_hash  (commit_hash) UNIQUE
#  index_git_commits_on_project_id   (project_id)
#  index_git_commits_on_robo_job_id  (robo_job_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id)
#  fk_rails_...  (robo_job_id => robo_jobs.id)
#
