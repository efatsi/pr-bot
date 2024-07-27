class Project < ApplicationRecord
  has_many :robo_jobs, dependent: :destroy
  has_many :robo_requests, through: :robo_jobs

  has_many :git_commits, dependent: :destroy

  validates :repo_path, :project_context, presence: true

  array_field :ignored_files

  # by_recency class method
  def self.by_recency
    all.sort_by { |p| p.robo_jobs.map(&:created_at).max || p.created_at }.reverse
  end

  def to_s
    repo_path
  end

  def parent_jobs
    robo_jobs.parent_jobs
  end

  def all_branches
    Dir.chdir(repo_path) do
      branches_output = `git branch`
      branches_output.split("\n").map { |b| b.strip.delete_prefix('* ') }
    end
  end

  def current_branch
    Dir.chdir(repo_path) do
      branches_output = `git branch`
      branches_output.match(/\* (.+)/)[1]
    end
  end

  def fetch_directory_tree(include_ignored_files: false)
    gitignore_path = File.join(repo_path, '.gitignore')
    ignore_patterns = []

    # Read the .gitignore file and build ignore patterns, if it exists
    if File.exist?(gitignore_path)
      File.foreach(gitignore_path) do |ignore_line|
        ignore_line = ignore_line.strip

        # Skip comments and empty lines
        next if ignore_line.start_with?('#') || ignore_line.empty?

        # Remove leading slash
        ignore_line = ignore_line.gsub(%r{^/}, '')

        # Add glob pattern for root, subdirectory, and recursive subdirectory
        ignore_patterns << File.join(repo_path, ignore_line)
        ignore_patterns << File.join(repo_path, ignore_line, "*")
        ignore_patterns << File.join(repo_path, "**", ignore_line)
        ignore_patterns << File.join(repo_path, "**", ignore_line, "*")
      end
    end

    # Find all files and reject directories and files matching ignore patterns
    files = Dir.glob("#{repo_path}/**/*").reject do |file|
      File.directory?(file) || ignore_patterns.any? do |pattern|
        File.fnmatch(pattern, file)
      end || (
        !include_ignored_files && ignored_files.any? { |i| File.fnmatch("#{repo_path}/#{i}", file) }
      )
    end

    # Remove the repo_path from the beginning of each file path
    files.map { |f| f.gsub(repo_path + "/", "") }
  end

  def full_path(f)
    if f.downcase.start_with?(repo_path.downcase)
      f
    else
      File.join(repo_path.downcase, f)
    end
  end

  def invalid_path?(path)
    path = File.join(repo_path, path)
    !File.exist?(path) || File.directory?(path)
  end

  require 'open3'

  def current_diff
    Dir.chdir(repo_path) do
      git_diff_output, status = Open3.capture2e('git diff')
      raise 'Failed to fetch git diff' unless status.success?

      git_diff_output
    rescue => e
      puts e.message
      nil
    end
  end

  def any_diff_available?
    current_diff.present?
  end

  def file_content_search(query:, regex: false, case_sensitive: false)
    return [] if query.blank?

    file_list = fetch_directory_tree
    matching_files = file_list.each_with_object([]) do |file, acc|
      file_path = File.join(repo_path, file)
      content_lines = (File.read(file_path)
        .force_encoding('UTF-8')
        .encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
        .split("\n")
      )

      matching_lines = content_lines.map.with_index do |line, index|
        match = if regex
          regex_pattern = case_sensitive ? Regexp.new(query) : Regexp.new(query, Regexp::IGNORECASE)
          line.match(regex_pattern)
        else
          case_sensitive ? line.include?(query) : line.downcase.include?(query.downcase)
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

    matching_files
  end
end

# == Schema Information
#
# Table name: projects
#
#  id              :bigint           not null, primary key
#  ignored_files   :string           default([]), is an Array
#  project_context :text             not null
#  repo_path       :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
