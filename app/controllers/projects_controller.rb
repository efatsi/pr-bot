class ProjectsController < ApplicationController
  def index
  end

  def show
    project.scrub_pending_commits
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)

    if project.save
      redirect_to projects_path
    else
      render :new
    end
  end

  def edit
  end

  def update
    if project.update(project_params)
      redirect_to projects_path
    else
      render :edit
    end
  end

  def fuzzy_finder
  end

  def file_preview
    full_path = File.join(project.filepath, params[:file])
    file_contents = File.read(full_path)

    render plain: file_contents
  end

  private

  helper_method :project
  def project
    @project ||= Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:filepath, :project_context, :ignored_files)
  end
end
