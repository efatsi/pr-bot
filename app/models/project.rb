class Project < ApplicationRecord
  has_many :robo_jobs, dependent: :destroy
  has_many :robo_requests, through: :robo_jobs

  validates :filepath, :project_context, presence: true

  array_field :ignored_files, alphabetize: true

  def to_s
    filepath
  end

  def parent_jobs
    robo_jobs.parent_jobs
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
        # direct lookup on ignored_files is faster than using File.fnmatch + globbing
        !include_ignored_files && ignored_files.any? { |ignored| file.include?(ignored) }
      )
    end

    # Remove the filepath from the beginning of each file path
    files.map { |f| f.gsub(filepath + "/", "") }
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
