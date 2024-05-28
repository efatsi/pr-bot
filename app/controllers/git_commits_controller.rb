class GitCommitsController < ApplicationController
  def new
    @git_commit = robo_job.git_commits.create

    @robo_event = RoboEvent.create!(
      event_type: "commit_suggestions",
      robots: selected_robots,
      subject: git_commit,
      parent_robo_event: robo_job.last_active_event
    )

    render turbo_stream: turbo_stream.update(
      "next-steps",
      partial: "robo_events/list_item",
      locals: { robo_event: robo_event }
    )
  end

  def update
    if git_commit.update(git_commit_params) && git_commit.fire!
      flash[:notice] = "Git commit saved"

      render turbo_stream: [
        turbo_stream.update(
          "robo-event-#{robo_event.id}",
          partial: "robo_events/list_item",
          locals: { robo_event: robo_event }
        ),
        turbo_stream.update(
          "flash",
          partial: "shared/flash",
          locals: { flash: flash }
        )
      ]

    else
      render "robo_events/git_commit/input", status: :unprocessable_entity, alert: "Git commit failed: #{git_commit.error}"
    end
  end

  def generate_options
    RoboConductor.new(robo_event).start_event
  end

  private

  def git_commit
    @git_commit ||= GitCommit.find(params[:id])
  end
  helper_method :git_commit

  def robo_event
    @robo_event ||= git_commit.robo_event
  end
  helper_method :robo_event

  def git_commit_params
    params.require(:git_commit).
      permit(:message, :branch, :new_branch).
      merge(robo_job_id: robo_job.id)
  end

  def robo_job
    @robo_job ||= if params[:robo_job_id]
      RoboJob.find_by(id: params[:robo_job_id])
    elsif git_commit
      git_commit.robo_job
    end
  end
  helper_method :robo_job
end
