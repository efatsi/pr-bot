class GitCommit < ApplicationRecord
  STATUSES = [
    "pending",
    "executed",
    "failed"
  ]

  belongs_to :project
  belongs_to :robo_job, optional: true

  has_many :robo_requests, as: :parent, dependent: :destroy

  attr_accessor :new_branch

  STATUSES.each do |status|
    scope status, -> { where(status: status) }

    define_method("#{status}?") do
      self.status == status
    end
  end

  def fire!
    Dir.chdir(project.filepath) do
      if new_branch.present?
        `git branch -D #{new_branch}; git checkout -b #{new_branch}`
        update(branch: new_branch)
      else
        `git checkout #{branch}`
      end

      commit_output, status = Open3.capture2e("git add -A; git commit -m \"#{message}\"")
      if status.success?
        update(
          status: "executed",
          response: commit_output,
          commit_hash: commit_output.match(/\[#{branch} ([a-z0-9]+)\]/)[1]
        )
        true
      else
        update(status: "failed", response: commit_output)
        false
      end
    end
  end
end

# == Schema Information
#
# Table name: git_commits
#
#  id              :bigint           not null, primary key
#  branch          :string
#  commit_hash     :string
#  error           :string
#  message         :text
#  message_options :json
#  response        :text
#  status          :string           default("pending")
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  project_id      :bigint           not null
#  robo_job_id     :bigint
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
