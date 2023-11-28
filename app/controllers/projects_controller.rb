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

  def file_name_search
    if params[:query].blank?
      return render json: []
    end

    file_list = project.fetch_directory_tree
    search_terms = params[:query].split(/\/|\s/).map(&:downcase).reject(&:empty?)

    # Ensure that the search terms appear in the file name in the order they were entered
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

    file_list = project.fetch_directory_tree
    matching_files = file_list.select do |file|
      file_path = File.join(project.filepath, file)
      content = File.read(file_path)

      if params[:regex] == 'true'
        begin
          if params[:case_sensitive] == 'true'
            regex = Regexp.new(params[:query])
            match = content.match(regex)
          else
            regex = Regexp.new(params[:query].downcase)
            match = content.downcase.match(regex)
          end
        rescue RegexpError => e
          render json: { error: e.message }, status: :bad_request
          return
        end
        match
      else
        if params[:case_sensitive] == 'true'
          content.include?(params[:query])
        else
          content.downcase.include?(params[:query].downcase)
        end
      end

    end
    render json: matching_files
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
