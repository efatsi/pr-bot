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

    file_list = project.fetch_directory_tree
    matching_files = file_list.each_with_object([]) do |file, acc|
      file_path = File.join(project.filepath, file)
      content_lines = File.read(file_path).split("\n")

      matching_lines = content_lines.map.with_index do |line, index|
        match = if params[:regex] == 'true'
          regex = params[:case_sensitive] == 'true' ? Regexp.new(params[:query]) : Regexp.new(params[:query], Regexp::IGNORECASE)
          line.match(regex)
        else
          params[:case_sensitive] == 'true' ? line.include?(params[:query]) : line.downcase.include?(params[:query].downcase)
        end

        index if match
      end.compact

      if matching_lines.any?
        buffered_matching_lines = matching_lines.flat_map { |line| [(line - 2), (line - 1), line, (line + 1), (line + 2)] }.uniq.sort
        buffered_matching_lines.reject! { |l| l < 0 || l >= content_lines.length }

        grouped_lines = buffered_matching_lines.slice_when { |i, j| i + 1 != j }.to_a
        grouped_line_content = grouped_lines.map do |group|
          # Remove the first and last line of each group unless it's the top or bottom of the file
          group.shift unless group.first == 0
          group.pop unless group.last == content_lines.length - 1
          group.map { |line_number| { line: line_number, content: content_lines[line_number] } }.compact
        end
        acc << { file: file, line_groups: grouped_line_content }
      end
    end

    render json: matching_files
  end

  def full_directory_listing
    render json: project.fetch_directory_tree
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
