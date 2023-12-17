class CommitRunnerJob < ApplicationJob
  def perform(git_commit_id, action)
    git_commit = GitCommit.find(git_commit_id)

    RoboManager.new(git_commit, action).run_request
  end
end
