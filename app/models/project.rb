class Project < ApplicationRecord
  has_many :robo_jobs

  validates :filepath, :project_context, presence: true

  array_field :ignored_files, alphabetize: true

  def to_s
    filepath
  end

  def fetch_directory_tree(include_ignored_files: false)
    gitignore_path = File.join(filepath, '.gitignore')
    ignore_patterns = include_ignored_files ? [] : ignored_files.dup

    # Read the .gitignore file and build ignore patterns, if it exists
    if File.exist?(gitignore_path)
      File.foreach(gitignore_path) do |line|
        stripped = line.strip
        # Skip comments and empty lines
        next if stripped.start_with?('#') || stripped.empty?
        # Convert the gitignore pattern to a glob pattern
        glob_pattern = stripped.gsub(%r{^/}, '') # Remove leading slash

        # Add glob pattern for root, subdirectory, and recursive subdirectory
        ignore_patterns << File.join(filepath, glob_pattern)
        ignore_patterns << File.join(filepath, glob_pattern, "*")
        ignore_patterns << File.join(filepath, "**", glob_pattern)
        ignore_patterns << File.join(filepath, "**", glob_pattern, "*")
      end
    end

    # Find all files and reject directories and files matching ignore patterns
    files = Dir.glob("#{filepath}/**/*").reject do |e|
      File.directory?(e) || ignore_patterns.any? do |pattern|
        full_pattern = File.join(filepath, pattern)
        File.fnmatch(full_pattern, e)
      end
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
