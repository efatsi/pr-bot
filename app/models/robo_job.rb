class RoboJob < ApplicationRecord
  has_many :robo_requests

  validates :filepath, presence: true
  validates :feature_request, presence: true

  def prepare_request(type)
    robo_requests.new(request_type: type)
  end

  def ask_for_contextual_files(robo_request)
    robo_request.fire!

    if robo_request.response
      self.update(relevant_files: robo_request.response.scan(/[\w\-.\/]+/).select { |f| File.file?(f) })
    else
      raise "Error: #{robo_request.raw_response}"
    end
  end

  def ask_for_instructions
    robo_request = robo_requests.new(request_type: "request_instructions")
    robo_request.fire!

    if robo_request.response
      self.update(generated_instructions: robo_request.response)
    else
      raise "Error: #{robo_request.raw_response}"
    end
  end

  def fetch_directory_tree
    gitignore_path = File.join(filepath, '.gitignore')
    ignore_patterns = ["./public/*", "./playground/*", "./db/migrate/*"]

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
    Dir.glob("#{filepath}/**/*").reject do |e|
      File.directory?(e) || ignore_patterns.any? { |pattern| File.fnmatch(pattern, e) }
    end
  end

  def contextual_file_data
    relevant_files.map { |f| { name: f, content: File.read(f) } }
  end
end

# == Schema Information
#
# Table name: robo_jobs
#
#  id                     :bigint           not null, primary key
#  feature_request        :text             not null
#  filepath               :string           not null
#  generated_instructions :text
#  project_context        :text
#  relevant_files         :string           default([]), is an Array
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
