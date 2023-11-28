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

    render json: matching_files.map { |f| { file: f } }
  end

  def file_content_search
    if params[:query].blank?
      return render json: []
    end

    file_list = project.fetch_directory_tree
    matching_files = file_list.each_with_object([]) do |file, acc|
      file_path = File.join(project.filepath, file)
      content = File.read(file_path)

      content_lines = content.split("\n")
      content_lines.each_with_index do |line, index|
        if params[:regex] == 'true'
          begin
            regex = params[:case_sensitive] == 'true' ? Regexp.new(params[:query]) : Regexp.new(params[:query], Regexp::IGNORECASE)
            match = line.match(regex)
          rescue RegexpError => e
            return render json: { error: e.message }, status: :bad_request
          end
        else
          match = params[:case_sensitive] == 'true' ? line.include?(params[:query]) : line.downcase.include?(params[:query].downcase)
        end

        if match
          surrounding_lines = content_lines[[index - 1, 0].max..[index + 1, content_lines.length - 1].min].select(&:present?).compact
          acc << { file: file, line: index + 1, surrounding_lines: surrounding_lines }
          break
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
