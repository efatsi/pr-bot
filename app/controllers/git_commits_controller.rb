class GitCommitsController < SseApplicationController
  before_action :set_sse_headers, only: :generate_options

  def new
    @git_commit = project.git_commits.create
    redirect_to edit_project_git_commit_path(project, @git_commit)
  end

  def edit
  end

  def update
    if git_commit.update(git_commit_params)
      git_commit.fire!
      redirect_to robo_job || project, notice: 'Git commit saved'
    else
      render :new
    end
  end

  def generate_options
    robo_manager = RoboManager.new(git_commit, "commit_suggestions")

    sse.write({
      turbo_stream: turbo_stream.update(
        "commit-suggestions",
        partial: "git_commits/suggestions/processing",
        locals: { robo_request: robo_manager.robo_request }
      )
    })

    robo_manager.run_request(sse_proc)

    sse.write({
      turbo_stream: turbo_stream.update(
        "commit-suggestions",
        partial: "git_commits/suggestions/finished",
        locals: { robo_request: robo_manager.robo_request, git_commit: git_commit }
      )
    })
  ensure
    sse.close
  end

  private

  def git_commit
    @git_commit ||= project.git_commits.find_by!(id: params[:id])
  end
  helper_method :git_commit

  def git_commit_params
    gc_params = params.require(:git_commit).permit(:message, :branch).merge(project_id: project.id)

    if robo_job.present?
      gc_params.merge(robo_job_id: robo_job.id)
    else
      gc_params
    end
  end

  # Should always have a project
  def project
    @project ||= Project.find_by!(id: params[:project_id])
  end
  helper_method :project

  # Sometimes have a robo_job
  def robo_job
    @robo_job ||= RoboJob.find_by(id: params[:robo_job_id])
  end
  helper_method :robo_job
end
