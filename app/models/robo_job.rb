class RoboJob < ApplicationRecord
  has_many :robo_requests, -> { by_id }, dependent: :destroy
  has_many :robo_changes, -> { by_id }, dependent: :destroy

  belongs_to :project

  # Can have many followup jobs, or be a parent job
  has_many :followup_jobs, class_name: "RoboJob", foreign_key: :parent_job_id
  belongs_to :parent_job, class_name: "RoboJob", optional: true

  validates :feature_request, presence: true

  array_field :contextual_files

  scope :parent_jobs, -> { where(parent_job_id: nil) }

  def prepare_request(type)
    robo_requests.new(request_type: type)
  end

  def run_request(robo_request, sse_proc=nil)
    robo_request.fire!(sse_proc)

    if robo_request.response
      case robo_request.request_type
      when "contextual_files"
        contextual_files = robo_request.response.scan(/[\w\-.\/]+/).select do |f|
          full_filepath = full_path(f)

          # Is file, is directory, is not just a dot and/or slash
          File.file?(full_filepath) || File.directory?(full_filepath) &&
            f.gsub(/[\.\/]/, "").length > 0
        end

        self.update(contextual_files: unpack_paths(contextual_files))
      when "instructions"
        self.update(generated_instructions: robo_request.response)
        self.process_instructions_to_changes
      end
    else
      raise "Error: #{robo_request.raw_response}"
    end
  end

  def contextual_file_data
    contextual_files.map do |file|
      {
        name: file,
        content: File.read(full_path(file))
      }
    end
  end

  def parsed_instructions
    @parsed_instructions ||= JSON.parse(generated_instructions)
  end

  def all_robo_changes
    if is_parent_job?
      RoboChange.where(robo_job_id: [id, *followup_job_ids])
    else
      robo_changes
    end
  end

  private

  def is_parent_job?
    parent_job_id.nil?
  end

  def process_instructions_to_changes
    robo_changes.destroy_all

    parsed_instructions["changes"].each do |changeset|
      if "[timestamp]".in? changeset["file"].downcase
        changeset["file"] = changeset["file"].gsub(/\[timestamp\]/i, Time.now.strftime("%Y%m%d%H%M%S"))
      end

      robo_changes.create(
        **changeset,
        raw_json: changeset
      )
    end
  end

  def unpack_paths(paths)
    paths.map do |f|
      full_filepath = full_path(f)

      if File.file?(full_filepath)
        f
      elsif File.directory?(full_filepath)
        glob_path = File.join(full_filepath, "*")
        subpaths = Dir.glob(glob_path).map do |subpath|
          subpath.gsub(project.filepath, "")
        end
        unpack_paths(subpaths)
      end
    end.flatten
  end

  def full_path(f)
    File.join(project.filepath, f)
  end
end

# == Schema Information
#
# Table name: robo_jobs
#
#  id                     :bigint           not null, primary key
#  contextual_files       :string           default([]), is an Array
#  feature_request        :text             not null
#  generated_instructions :text
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  parent_job_id          :bigint
#  project_id             :bigint
#
# Indexes
#
#  index_robo_jobs_on_parent_job_id  (parent_job_id)
#  index_robo_jobs_on_project_id     (project_id)
#
# Foreign Keys
#
#  fk_rails_...  (parent_job_id => robo_jobs.id)
#  fk_rails_...  (project_id => projects.id)
#
