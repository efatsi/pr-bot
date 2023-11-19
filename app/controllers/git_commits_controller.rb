class GitCommitsController < ApplicationController
  def new
    @git_commit = GitCommit.new
  end

  def create
    @git_commit = GitCommit.new(git_commit_params)

    if @git_commit.save
      redirect_to robo_job || project, notice: 'Git commit was successfully created.'
    else
      render :new
    end
  end

  private

  def git_commit_params
    gc_params = params.require(:git_commit).permit(:commit_hash, :message).merge(project_id: project.id)

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
