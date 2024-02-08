class Project < ApplicationRecord
  has_many :robo_jobs, dependent: :destroy
  has_many :robo_requests, through: :robo_jobs

  has_many :git_commits, dependent: :destroy

  validates :filepath, :project_context, presence: true

  array_field :ignored_files

  def to_s
    filepath
  end

  def parent_jobs
    robo_jobs.parent_jobs
  end

  def all_branches
    Dir.chdir(filepath) do
      branches_output = `git branch`
      branches_output.split("\n").map { |b| b.strip.delete_prefix('* ') }
    end
  end

  def current_branch
    Dir.chdir(filepath) do
      branches_output = `git branch`
      branches_output.match(/\* (.+)/)[1]
    end
  end

  def fetch_directory_tree(include_ignored_files: false)
    gitignore_path = File.join(filepath, '.gitignore')
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
        ignore_patterns << File.join(filepath, ignore_line)
        ignore_patterns << File.join(filepath, ignore_line, "*")
        ignore_patterns << File.join(filepath, "**", ignore_line)
        ignore_patterns << File.join(filepath, "**", ignore_line, "*")
      end
    end

    # Find all files and reject directories and files matching ignore patterns
    files = Dir.glob("#{filepath}/**/*").reject do |file|
      File.directory?(file) || ignore_patterns.any? do |pattern|
        File.fnmatch(pattern, file)
      end || (
        !include_ignored_files && ignored_files.any? { |i| File.fnmatch("#{filepath}/#{i}", file) }
      )
    end

    # Remove the filepath from the beginning of each file path
    files.map { |f| f.gsub(filepath + "/", "") }
  end

  def full_path(f)
    if f.downcase.start_with?(filepath.downcase)
      f
    else
      File.join(filepath.downcase, f)
    end
  end

  def invalid_path?(path)
    path = File.join(filepath, path)
    !File.exist?(path) || File.directory?(path)
  end

  require 'open3'

  def current_diff
    Dir.chdir(filepath) do
      git_diff_output, status = Open3.capture2e('git diff')
      raise 'Failed to fetch git diff' unless status.success?

      git_diff_output
    rescue => e
      puts e.message
      nil
    end
  end

  def scrub_pending_commits
    git_commits.pending.destroy_all
  end
end

# == Schema Information
#
# Table name: projects
#
#  id              :bigint           not null, primary key
#  filepath        :string           not null
#  ignored_files   :string           default([]), is an Array
#  project_context :text             not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
