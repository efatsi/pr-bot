module JobRunners::FollowupInstructions
  class Runner < JobRunners::Instructions::Runner

    # mostly the same functionality as main Instructions runner
    # different broadcast messages and primary target/label

    private

    def broadcast_finished_state
      broadcast(
        target: "actions",
        partial: 'robo_jobs/instructions/actions',
        locals: {
          robo_job: robo_job.parent_job.reload,
          ding: true
        }
      )
    end

  end
end
