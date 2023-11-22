class GitCommitsController < SseApplicationController
  before_action :set_sse_headers, only: :generate_options

  def new
    if params[:robo_job_id]
      @git_commit = (
        project.git_commits.pending.find_by(robo_job_id: params[:robo_job_id]) ||
        project.git_commits.create(robo_job_id: params[:robo_job_id])
      )
    else
      @git_commit = project.git_commits.pending.last || project.git_commits.create
    end

    redirect_to edit_project_git_commit_path(project, @git_commit, modal: params[:modal], robo_job_id: params[:robo_job_id])
  end

  def edit
    if params[:modal]
      render layout: "modal_wrapper"
    end
  end

  def update
    if git_commit.update(git_commit_params) && git_commit.fire!
      if robo_job
        flash[:notice] = "Git commit saved"

        render turbo_stream: [
          turbo_stream.update("turbo_scripts", partial: "shared/close_modal"),
          turbo_stream.update("flash", partial: "shared/flash", locals: { flash: flash })
        ]
      else
        redirect_to project, notice: 'Git commit saved'
      end
    else
      render :edit, status: :unprocessable_entity, alert: "Git commit failed: #{git_commit.error}"
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
    gc_params = params.require(:git_commit).permit(:message, :branch, :new_branch).merge(project_id: project.id)

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
