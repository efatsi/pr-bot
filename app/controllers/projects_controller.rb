class ProjectsController < ApplicationController
  def index
  end

  def show
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
      redirect_to project
    else
      render :edit
    end
  end

  def fuzzy_finder
    if params[:file].present?
      @file_preview = params[:file]
    end
  end

  def file_name_search
    if params[:query].blank?
      return render json: []
    end

    file_list = project.fetch_directory_tree
    search_terms = params[:query].split(/\/|\s/).map(&:downcase).reject(&:empty?)

    # Ensure that the search terms appear in the filepath in the order they were entered
    matching_files = file_list.select do |file|
      last_index = -1
      sequence_found = search_terms.all? do |term|
        current_index = file.downcase.index(term, last_index + 1)
        if current_index.nil? || (last_index != -1 && current_index <= last_index)
          false
        else
          last_index = current_index
          true
        end
      end
      sequence_found
    end

    render json: matching_files
  end

  def file_content_search
    if params[:query].blank?
      return render json: []
    end

    matching_files = project.file_content_search(
      query: params[:query],
      regex: params[:regex] == 'true',
      case_sensitive: params[:case_sensitive] == 'true'
    )

    render json: matching_files
  end

  def full_directory_listing
    render json: project.fetch_directory_tree
  end

  def file_preview
    full_filepath = File.join(project.repo_path, params[:file])
    file_contents = File.read(full_filepath)

    render plain: file_contents
  end

  private

  helper_method :project
  def project
    @project ||= Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:repo_path, :project_context, :ignored_files)
  end
end
